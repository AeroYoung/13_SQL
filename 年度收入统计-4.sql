-- =============================================
-- Author:		杨尧
-- Create date: 2017-03-21 
-- Description:	年度收入统计 仅返回一个表
-- =============================================
if OBJECT_ID(N'dbo.AnnualRevenueStatistic4', N'P') is NOT null 
DROP procedure  AnnualRevenueStatistic4 
GO
CREATE PROCEDURE AnnualRevenueStatistic4
	@year int = 2017, --年份
	@isBillCheck int = 0 -- 1仅对账 -1仅不对账 0全部
AS
BEGIN

BEGIN--1 数据源-从整车试验数据和炭罐试验数据中复制

select year(preStartDate) as y,month(preStartDate) as m,'整车试验' as FormType,SHED as equipment,
taskType,billCheck,CAST(1 as varchar(MAX)) as num,
cost,costVehicle,costPurge,costRVP,costFuel,costVehicleOther,
CAST(0 as varchar(MAX)) as costVolume,CAST(0 as varchar(MAX)) as costBWC,CAST(0 as varchar(MAX)) as costGWC,
CAST(0 as varchar(MAX)) as costVentilate,CAST(0 as varchar(MAX)) as costSeal,CAST(0 as varchar(MAX)) as costCanisterOther
into #data from VehicleDataTable where year(preStartDate)=@year 

insert into #data select year(receiveDate) as y,month(receiveDate) as m,'炭罐试验' as FormType,
BWCequipment as equipment,taskType,billCheck,totalTime,
cost,'0' as costVehicle,'0' as costPurge,'0' as costRVP,'0' as costFuel,'0' as costVehicleOther,
costVolume,costBWC,costGWC,costVentilate,costSeal,costCanisterOther
from CanisterDataTable where year(receiveDate)=@year

END 

BEGIN--2 数据格式清理

	BEGIN--修正对账工作为0,1 然后决定是否删除
		update #data set billCheck='1' where billCheck='是'  OR billCheck='1' or billCheck='TRUE'
		update #data set billCheck='0' where billCheck<>'1'
		if(@isBillCheck = 1)
		BEGIN
			delete #data where billCheck<>'1'
		END
		ELSE IF(@isBillCheck = -1)
		BEGIN
			delete #data where billCheck<>'0'
		END
	END
	
	update #data set num=0 where ISNUMERIC(num)=0
	
	BEGIN--修正费用
		update #data set costVehicle=0 where ISNUMERIC(costVehicle)=0
		update #data set costPurge=0 where ISNUMERIC(costPurge)=0
		update #data set costRVP=0 where ISNUMERIC(costRVP)=0
		update #data set costFuel=0 where ISNUMERIC(costFuel)=0
		update #data set costVehicleOther=0 where ISNUMERIC(costVehicleOther)=0
		update #data set costVolume=0 where ISNUMERIC(costVolume)=0
		update #data set costBWC=0 where ISNUMERIC(costBWC)=0
		update #data set costGWC=0 where ISNUMERIC(costGWC)=0
		update #data set costVentilate=0 where ISNUMERIC(costVentilate)=0
		update #data set costSeal=0 where ISNUMERIC(costSeal)=0
		update #data set costCanisterOther=0 where ISNUMERIC(costCanisterOther)=0
		
		update #data set cost=cast(costVehicle as float)+cast(costPurge as float)+cast(costRVP as float)+cast(costFuel as float)+cast(costVehicleOther as float)
			+cast(costVolume as float)+cast(costBWC as float)+cast(costGWC as float)+cast(costVentilate as float)+cast(costSeal as float)+cast(costCanisterOther as float)
	END

END

BEGIN--3 修正taskType
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
		
		FETCH NEXT FROM taskCursor INTO @taskTypeName
	END 
	CLOSE taskCursor--关闭游标  
	DEALLOCATE taskCursor--释放游标  
	
	update #data set taskType='其它' where taskType not in (select distinct taskType from TaskTypeTable)
END

/**********************以下开始插入数据到StatisticAnnualRevenue**********************/

BEGIN--1 rowHeaders 

	DECLARE @rowHeaders AnnualStatistic
	
	insert into @rowHeaders values('总体','整车试验','FormType',null,null,null)
	insert into @rowHeaders values('总体','炭罐试验','FormType',null,null,null)
	
	insert into @rowHeaders select '整车任务',taskTyPE,'taskType',null,null,null FROM TaskTypeTable 
	insert into @rowHeaders select '炭罐任务',taskTyPE,'taskType',null,null,null FROM TaskTypeTable 

	insert into @rowHeaders select '设备',equipType,null,equipID,costSource,equipSorce FROM EquipmentTable order by ID

END

BEGIN--2 rowHeaders插入空白数值到StatisticAnnualRevenue

delete StatisticAnnualRevenue where [year]=@year
update @rowHeaders set equipment='' where equipment is null
insert into StatisticAnnualRevenue([year],type1,type2,equipment) select @year,type1,type2,equipment from @rowHeaders ORDER BY ID

END

BEGIN--3 遍历rowHeaders插入数值到StatisticAnnualRevenue

	DECLARE @type1 varchar(max),@type2 varchar(max),@type2Col varchar(max),
		@equipment varchar(max),@costSource varchar(max),@equipSource varchar(max)--变量
	
	DECLARE rowHeaderCursor CURSOR FOR SELECT type1,type2,type2Col,equipment,costSource,equipSource
		 FROM @rowHeaders --游标
	OPEN rowHeaderCursor--打开游标	
	FETCH NEXT FROM rowHeaderCursor INTO @type1,@type2,@type2Col,@equipment,@costSource,@equipSource--取出值  
	 
	WHILE @@FETCH_STATUS=0--循环取出游标的值 
	BEGIN 
		--循环1~12月
		DECLARE @i int
		SET @i = 1
		WHILE @i<=12
		BEGIN
			DECLARE @strsql varchar(MAX),@strwhere varchar(MAX)
			
			if(@type2Col is not null) -- 任务和总体
			BEGIN
				if(@type1='总体')
				BEGIN
				
				SET @strwhere=' where y='+cast(@year as varchar(10)) +' AND m='+cast(@i as varchar(10))
				SET @strwhere+=' and '+@type2Col+'='''+@type2+''' ) '	
				SET @strwhere+=' where [year]='+cast(@year as varchar(10))+' and type1='''+@type1+''' and type2='''+@type2+''' and equipment='''+@equipment+''''
				
				END
				ELSE
				BEGIN
				
				SET @strwhere=' where y='+cast(@year as varchar(10)) +' AND m='+cast(@i as varchar(10))
				SET @strwhere+=' and '+@type2Col+'='''+@type2+''' AND FormType='''+ left(@type1,2) +'试验'') '	
				SET @strwhere+=' where [year]='+cast(@year as varchar(10))+' and type1='''+@type1+''' and type2='''+@type2+''' and equipment='''+@equipment+''''
								
				END
				--金额
				SET @strsql='update StatisticAnnualRevenue set cost'+CAST(@i AS VARCHAR(10))+' = (select SUM(cast(cost as float)) from #data '
				EXEC(@strSql+@strwhere)				
				--数量
				SET @strsql='update StatisticAnnualRevenue set num'+CAST(@i AS VARCHAR(10))+' = (select SUM(cast(num as float)) from #data '
				EXEC(@strSql+@strwhere)			
			END
			ELSE --按试验设备
			BEGIN
				SET @strsql='update StatisticAnnualRevenue set cost'+CAST(@i AS VARCHAR(10))
				SET @strsql+=' = (select SUM(cast('+@costSource+' as float)) from #data '
			
				if(@equipSource is null or @equipSource='') --一种费用构造只对应一个设备,#data中没有设备名称列
				BEGIN
					SET @strwhere=' where y='+cast(@year as varchar(10)) +' AND m='+cast(@i as varchar(10))
					SET @strwhere+=') '--不需要区分#data中的equipment
					SET @strwhere+=' where [year]='+cast(@year as varchar(10))+' and type1='''+@type1+''' and type2='''+@type2+''' and equipment='''+@equipment+''''
					--金额
					PRINT(@strSql+@strwhere)
					EXEC(@strSql+@strwhere)
					--数量
					SET @strsql='update StatisticAnnualRevenue set num'+CAST(@i AS VARCHAR(10))+' = (select SUM(cast(num as float)) from #data '
					SET @strwhere=' where y='+cast(@year as varchar(10)) +' AND m='+cast(@i as varchar(10))
					SET @strwhere+=' and cast('+@costSource+' as float)>0 ) '
					SET @strwhere+=' where [year]='+cast(@year as varchar(10))+' and type1='''+@type1+''' and type2='''+@type2+''' and equipment='''+@equipment+''''
					EXEC(@strSql+@strwhere)	
				END
				ELSE										--一种费用构造对应多个设备,#data中有设备名称列
				BEGIN					
					SET @strwhere=' where y='+cast(@year as varchar(10)) +' AND m='+cast(@i as varchar(10))
					SET @strwhere+=' and equipment='''+@equipment+''' ) '--需要区分#data中的equipment
					SET @strwhere+=' where [year]='+cast(@year as varchar(10))+' and type1='''+@type1+''' and type2='''+@type2+''' and equipment='''+@equipment+''''
					--金额
					PRINT(@strSql+@strwhere)
					EXEC(@strSql+@strwhere)
					--数量
					SET @strsql='update StatisticAnnualRevenue set num'+CAST(@i AS VARCHAR(10))+' = (select SUM(cast(num as float)) from #data '
					EXEC(@strSql+@strwhere)	
				END
			END
			
			SET @i= @i+1
		END --WHILE
		
		FETCH NEXT FROM rowHeaderCursor INTO @type1,@type2,@type2Col,@equipment,@costSource,@equipSource--取出值 
	END 
	CLOSE rowHeaderCursor--关闭游标  
	DEALLOCATE rowHeaderCursor--释放游标  

END

BEGIN--年度总计
update StatisticAnnualRevenue set num1=0 where num1 is null
update StatisticAnnualRevenue set num2=0 where num2 is null
update StatisticAnnualRevenue set num3=0 where num3 is null
update StatisticAnnualRevenue set num4=0 where num4 is null
update StatisticAnnualRevenue set num5=0 where num5 is null
update StatisticAnnualRevenue set num6=0 where num6 is null
update StatisticAnnualRevenue set num7=0 where num7 is null
update StatisticAnnualRevenue set num8=0 where num8 is null
update StatisticAnnualRevenue set num9=0 where num9 is null
update StatisticAnnualRevenue set num10=0 where num10 is null
update StatisticAnnualRevenue set num11=0 where num11 is null
update StatisticAnnualRevenue set num12=0 where num12 is null

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

/********************************以下开始输入数据************************************/

--tables[0] 所有信息
select * from StatisticAnnualRevenue where [year]=@year order by ID 

END --CREATE PROCEDURE
