-- =============================================
-- Author:		杨尧
-- Create date: 2017-03-15
-- Description:	年度收入统计
-- =============================================
if OBJECT_ID(N'dbo.AnnualRevenueStatistic1', N'P') is NOT null 
DROP procedure  AnnualRevenueStatistic1 
GO
CREATE PROCEDURE AnnualRevenueStatistic1
	@year int = 2017 --年份
AS
BEGIN

--0 rowHeaders
DECLARE @rowHeaders AnnualStatistic

insert into @rowHeaders values('总体','整车试验','FormType',null)
insert into @rowHeaders values('总体','炭罐试验','FormType',null)

BEGIN--1 数据源-从整车试验数据和炭罐试验数据中复制

select year(preStartDate) as y,month(preStartDate) as m,'整车试验' as FormType,SHED as equipment,
taskType,billCheck,cost,costVehicle,costPurge,costRVP,costFuel,0.0 as costVolume,0.0 as costCapability
 into #data from VehicleDataTable where year(preStartDate)=@year

insert into #data select year(receiveDate) as y,month(receiveDate) as m,'炭罐试验' as FormType,
BWCequipment as equipment,taskType,billCheck,
cost,0.0 as costVehicle,0.0 as costPurge,0.0 as costRVP,0.0 as costFuel,costVolume,costCapability
from CanisterDataTable where year(receiveDate)=@year

END 

BEGIN--2 数据格式清理

	BEGIN--修正费用
		update #data set costVehicle=0 where ISNUMERIC(costVehicle)=0
		update #data set costPurge=0 where ISNUMERIC(costPurge)=0
		update #data set costRVP=0 where ISNUMERIC(costRVP)=0
		update #data set costFuel=0 where ISNUMERIC(costFuel)=0
		update #data set costVolume=0 where ISNUMERIC(costVolume)=0
		update #data set costCapability=0 where ISNUMERIC(costCapability)=0
		update #data set cost=cast(costVehicle as float)+cast(costPurge as float)+cast(costRVP as float)+cast(costFuel as float)+cast(costVolume as float)+cast(costCapability as float)
	END

	BEGIN--修正对账工作为0,1
		update #data set billCheck='1' where billCheck='是'
		update #data set billCheck='0' where billCheck<>'1'
	END
	
END

BEGIN--3 修正taskType & 插入rowHeaders 
	DECLARE @taskTypeName varchar(50) --申明变量  
	--申明一个游标  
	DECLARE taskCursor CURSOR FOR SELECT taskType FROM taskTypeTable
	--打开游标  
	OPEN taskCursor
	--取出值  
	FETCH NEXT FROM taskCursor INTO @taskTypeName
	--循环取出游标的值  
	WHILE @@FETCH_STATUS=0
	BEGIN 
		update #data set taskType=@taskTypeName where taskType like @taskTypeName
		insert into @rowHeaders values('任务',@taskTypeName,'taskType',null)--rowHeader
		FETCH NEXT FROM taskCursor INTO @taskTypeName
	END 
	CLOSE taskCursor--关闭游标  
	DEALLOCATE taskCursor--释放游标  
	
	update #data set taskType='其他' where taskType not in (select distinct taskType from TaskTypeTable)
END

BEGIN--4 修正设备 在设备表中没有的全都设为其他

update #data set equipment='其他' where equipment not in (select distinct equipID from EquipmentTable)

END

--select * from #data

/**********************以下开始插入数据到StatisticAnnualRevenue**********************/

BEGIN-- rowHeaders 设备

insert into @rowHeaders select distinct '设备',equipType,null,equipID FROM EquipmentTable where equipType='整车设备'
union all select distinct '设备',equipType,null,equipID FROM EquipmentTable where equipType='炭罐加载设备'
union all select distinct '设备',equipType,null,equipID FROM EquipmentTable where equipType<>'炭罐加载设备' and equipType<>'整车设备'

insert into @rowHeaders select distinct '设备',FormType,null,equipment FROM #data where equipment not in (select distinct equipID from EquipmentTable)

END

BEGIN--插入StatisticAnnualRevenue

delete StatisticAnnualRevenue where [year]=@year
update @rowHeaders set equipment='' where equipment is null
insert into StatisticAnnualRevenue([year],type1,type2,equipment) select @year,type1,type2,equipment from @rowHeaders

END

BEGIN--遍历rowHeaders取值

DECLARE @type1 varchar(max),@type2 varchar(max),@type2Col varchar(max),@equipment varchar(max) --申明变量  
DECLARE rowHeaderCursor CURSOR FOR SELECT * FROM @rowHeaders --申明一个游标
--打开游标  
OPEN rowHeaderCursor
--取出值  
FETCH NEXT FROM rowHeaderCursor INTO @type1,@type2,@type2Col,@equipment
--循环取出游标的值  
WHILE @@FETCH_STATUS=0
BEGIN 

	--循环1~12月
	DECLARE @i int
	SET @i = 1
	WHILE @i<=12
	BEGIN
		DECLARE @strsql varchar(MAX)
		
		SET @strsql='update StatisticAnnualRevenue set cost'+CAST(@i AS VARCHAR(10))+' = (select SUM(cast(cost as float)) from #data '
		
		DECLARE @strwhere varchar(MAX)
		if(@type2Col is not null)
		BEGIN
			SET @strwhere=' where y='+cast(@year as varchar(10)) +' AND m='+cast(@i as varchar(10))
			SET @strwhere+=' and '+@type2Col+'='''+@type2+''' ) '	
			--StatisticAnnualRevenue where
			SET @strwhere+=' where [year]='+cast(@year as varchar(10))+' and type1='''+@type1+''' and type2='''+@type2+''' and equipment='''+@equipment+''''
		END
		ELSE
		BEGIN
			SET @strwhere=' where y='+cast(@year as varchar(10)) +' AND m='+cast(@i as varchar(10))
			SET @strwhere+=' and equipment='''+@equipment+''' ) '	
			--StatisticAnnualRevenue where
			SET @strwhere+=' where [year]='+cast(@year as varchar(10))+' and type1='''+@type1+''' and type2='''+@type2+''' and equipment='''+@equipment+''''
		END
		
		--金额
		EXEC(@strSql+@strwhere)
		--print @strSql+@strwhere+'   '+cast(@@FETCH_STATUS as varchar(10))
		--数量
		SET @strsql='update StatisticAnnualRevenue set num'+CAST(@i AS VARCHAR(10))+' = (select count(*) from #data '
		EXEC(@strSql+@strwhere)
		
		SET @i= @i+1
	END --WHILE
	
	FETCH NEXT FROM rowHeaderCursor INTO @type1,@type2,@type2Col,@equipment
END 
CLOSE rowHeaderCursor--关闭游标  
DEALLOCATE rowHeaderCursor--释放游标  

END


BEGIN--年度总计
update StatisticAnnualRevenue set cost1=0 where cost1 is null
update StatisticAnnualRevenue set cost2=0 where cost2 is null
update StatisticAnnualRevenue set cost3=0 where cost3 is null
update StatisticAnnualRevenue set cost4=0 where cost4 is null
update StatisticAnnualRevenue set cost5=0 where cost5 is null
update StatisticAnnualRevenue set cost6=0 where cost6 is null
update StatisticAnnualRevenue set cost7=0 where cost7 is null
update StatisticAnnualRevenue set cost8=0 where cost8 is null
update StatisticAnnualRevenue set cost9=0 where cost9 is null
update StatisticAnnualRevenue set cost10=0 where cost10 is null
update StatisticAnnualRevenue set cost11=0 where cost11 is null
update StatisticAnnualRevenue set cost12=0 where cost12 is null
update StatisticAnnualRevenue set cost0=cost1+cost2+cost3+cost4+cost5+cost6+cost7+cost8+cost9+cost10+cost11+cost12 where [year]=@year
update StatisticAnnualRevenue set num0=num1+num2+num3+num4+num5+num6+num7+num8+num9+num10+num11+num12 where [year]=@year
END

select * from StatisticAnnualRevenue where [year]=@year order by ID


END --CREATE PROCEDURE
