-- =============================================
-- Author:		杨尧
-- Create date: 2017-03-20
-- Description:	年度收入统计
-- =============================================
if OBJECT_ID(N'dbo.AnnualRevenueStatistic2', N'P') is NOT null 
DROP procedure  AnnualRevenueStatistic2 
GO
CREATE PROCEDURE AnnualRevenueStatistic2
	@year int = 2017, --年份
	@isBillCheck int = 0 -- 1仅对账 -1仅不对账 0全部
AS
BEGIN

BEGIN--1 数据源-从整车试验数据和炭罐试验数据中复制

select year(preStartDate) as y,month(preStartDate) as m,'整车试验' as FormType,SHED as equipment,
taskType,billCheck,cost,costVehicle,costPurge,costRVP,costFuel,costVehicleOther,
CAST(0 as varchar(MAX)) as costVolume,CAST(0 as varchar(MAX)) as costBWC,CAST(0 as varchar(MAX)) as costGWC,
CAST(0 as varchar(MAX)) as costVentilate,CAST(0 as varchar(MAX)) as costSeal,CAST(0 as varchar(MAX)) as costCanisterOther
into #data from VehicleDataTable where year(preStartDate)=@year 

insert into #data select year(receiveDate) as y,month(receiveDate) as m,'炭罐试验' as FormType,
BWCequipment as equipment,taskType,billCheck,
cost,'0' as costVehicle,'0' as costPurge,'0' as costRVP,'0' as costFuel,'0' as costVehicleOther,
costVolume,costBWC,costGWC,costVentilate,costSeal,costCanisterOther
from CanisterDataTable where year(receiveDate)=@year

END 

BEGIN--2 数据格式清理

	BEGIN--修正对账工作为0,1 然后决定是否删除
		update #data set billCheck='1' where billCheck='是' OR billCheck='1' or billCheck='TRUE'
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
		
		FETCH NEXT FROM taskCursor INTO @taskTypeName
	END 
	CLOSE taskCursor--关闭游标  
	DEALLOCATE taskCursor--释放游标  
	
	update #data set taskType='其他' where taskType not in (select distinct taskType from TaskTypeTable)
END

--BEGIN--4 修正设备 在设备表中没有的全都设为其他

--update #data set equipment='其他' where equipment not in (select distinct equipID from EquipmentTable) and FormType='整车试验'
--update #data set equipment='其他' where equipment not in (select distinct equipID from EquipmentTable) and FormType='炭罐试验'

--END

/**********************以下开始插入数据到StatisticAnnualRevenue**********************/

BEGIN--1 rowHeaders 

	DECLARE @rowHeaders AnnualStatistic
	
	insert into @rowHeaders values('总体','整车试验','FormType',null,null,null)
	insert into @rowHeaders values('总体','炭罐试验','FormType',null,null,null)
	
	insert into @rowHeaders select '任务',taskTyPE,'taskType',null,null,null FROM TaskTypeTable 

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
				SET @strsql='update StatisticAnnualRevenue set cost'+CAST(@i AS VARCHAR(10))+' = (select SUM(cast(cost as float)) from #data '
			
				SET @strwhere=' where y='+cast(@year as varchar(10)) +' AND m='+cast(@i as varchar(10))
				SET @strwhere+=' and '+@type2Col+'='''+@type2+''' ) '	
				--StatisticAnnualRevenue where
				SET @strwhere+=' where [year]='+cast(@year as varchar(10))+' and type1='''+@type1+''' and type2='''+@type2+''' and equipment='''+@equipment+''''
			
				--金额
				EXEC(@strSql+@strwhere)
				
				--数量
				SET @strsql='update StatisticAnnualRevenue set num'+CAST(@i AS VARCHAR(10))+' = (select count(*) from #data '
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
					SET @strsql='update StatisticAnnualRevenue set num'+CAST(@i AS VARCHAR(10))+' = (select count(*) from #data '
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
					SET @strsql='update StatisticAnnualRevenue set num'+CAST(@i AS VARCHAR(10))+' = (select count(*) from #data '
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

--tables[1] 不分类别;按月;金额
select 
SUM(cost1) as m1,SUM(cost2) as m2,SUM(cost3) as m3,SUM(cost4) as m4,SUM(cost5) as m5,SUM(cost6) as m6,
SUM(cost7) as m7,SUM(cost8) as m8,SUM(cost9) as m9,SUM(cost10) as m10,SUM(cost11) as m11,SUM(cost12) as m12
from StatisticAnnualRevenue where [year]=@year and type1='总体'

--tables[2] 不分类别;按月;数量
select 
SUM(num1) as m1,SUM(num2) as m2,SUM(num3) as m3,SUM(num4) as m4,SUM(num5) as m5,SUM(num6) as m6,
SUM(num7) as m7,SUM(num8) as m8,SUM(num9) as m9,SUM(num10) as m10,SUM(num11) as m11,SUM(num12) as m12
from StatisticAnnualRevenue where [year]=@year and type1='总体'

--tables[3] 总体;按月;金额
select cost1,cost2,cost3,cost4,cost5,cost6,cost7,cost8,cost9,cost10,cost11,cost12,type2 as name
from StatisticAnnualRevenue where [year]=@year and type1='总体'

--tables[4] 总体;按月;数量
select num1,num2,num3,num4,num5,num6,num7,num8,num9,num10,num11,num12,type2 as name
from StatisticAnnualRevenue where [year]=@year and type1='总体'

--tables[5] 任务;按月;金额
select cost1,cost2,cost3,cost4,cost5,cost6,cost7,cost8,cost9,cost10,cost11,cost12,type2 as name
from StatisticAnnualRevenue where [year]=@year and type1='任务'

--tables[6] 任务;按月;数量
select num1,num2,num3,num4,num5,num6,num7,num8,num9,num10,num11,num12,type2 as name
from StatisticAnnualRevenue where [year]=@year and type1='任务'

--tables[7] 设备分类;按月;金额
select 
SUM(cost1) as m1,SUM(cost2) as m2,SUM(cost3) as m3,SUM(cost4) as m4,SUM(cost5) as m5,SUM(cost6) as m6,
SUM(cost7) as m7,SUM(cost8) as m8,SUM(cost9) as m9,SUM(cost10) as m10,SUM(cost11) as m11,SUM(cost12) as m12
,type2 as name
from StatisticAnnualRevenue where [year]=@year and type1='设备' group by type2 

--tables[8] 设备分类;按月;数量
select 
SUM(num1) as m1,SUM(num2) as m2,SUM(num3) as m3,SUM(num4) as m4,SUM(num5) as m5,SUM(num6) as m6,
SUM(num7) as m7,SUM(num8) as m8,SUM(num9) as m9,SUM(num10) as m10,SUM(num11) as m11,SUM(num12) as m12,
type2 as name
from StatisticAnnualRevenue where [year]=@year and type1='设备' group by type2 

--tables[9] 设备ID;按月;金额
select 
SUM(cost1) as m1,SUM(cost2) as m2,SUM(cost3) as m3,SUM(cost4) as m4,SUM(cost5) as m5,SUM(cost6) as m6,
SUM(cost7) as m7,SUM(cost8) as m8,SUM(cost9) as m9,SUM(cost10) as m10,SUM(cost11) as m11,SUM(cost12) as m12
,equipment as name
from StatisticAnnualRevenue where [year]=@year and type1='设备' group by equipment 

--tables[10] 设备ID;按月;数量
select 
SUM(num1) as m1,SUM(num2) as m2,SUM(num3) as m3,SUM(num4) as m4,SUM(num5) as m5,SUM(num6) as m6,
SUM(num7) as m7,SUM(num8) as m8,SUM(num9) as m9,SUM(num10) as m10,SUM(num11) as m11,SUM(num12) as m12
,equipment as name
from StatisticAnnualRevenue where [year]=@year and type1='设备' group by equipment 

--tables[11] 设备分类和设备ID;按月;金额
select 
SUM(cost1) as m1,SUM(cost2) as m2,SUM(cost3) as m3,SUM(cost4) as m4,SUM(cost5) as m5,SUM(cost6) as m6,
SUM(cost7) as m7,SUM(cost8) as m8,SUM(cost9) as m9,SUM(cost10) as m10,SUM(cost11) as m11,SUM(cost12) as m12
,type2+'-'+equipment as name
from StatisticAnnualRevenue where [year]=@year and type1='设备' group by type2,equipment 

--tables[12] 设备分类和设备ID;按月;数量
select 
SUM(num1) as m1,SUM(num2) as m2,SUM(num3) as m3,SUM(num4) as m4,SUM(num5) as m5,SUM(num6) as m6,
SUM(num7) as m7,SUM(num8) as m8,SUM(num9) as m9,SUM(num10) as m10,SUM(num11) as m11,SUM(num12) as m12
,+'-'+equipment as name
from StatisticAnnualRevenue where [year]=@year and type1='设备' group by type2,equipment 

--tables[13] 总体;按类别；金额,数量
select 
SUM(cost0) as cost,SUM(num0) as num,type2 as arg 
from StatisticAnnualRevenue where [year]=@year and type1='总体' group by type2

--tables[14] 任务;按类别；金额,数量
select 
SUM(cost0) as cost,SUM(num0) as num,type2 as arg 
from StatisticAnnualRevenue where [year]=@year and type1='任务' group by type2

--tables[15] 设备类别;按类别；金额,数量
select 
SUM(cost0) as cost,SUM(num0) as num,type2 as arg 
from StatisticAnnualRevenue where [year]=@year and type1='设备' group by type2

--tables[16] 设备ID;按类别；金额,数量
select 
SUM(cost0) as cost,SUM(num0) as num,equipment as arg 
from StatisticAnnualRevenue where [year]=@year and type1='设备' group by equipment

--tables[17] 设备ID和设备类别;按类别；金额,数量
select 
SUM(cost0) as cost,SUM(num0) as num,type2+equipment as arg 
from StatisticAnnualRevenue where [year]=@year and type1='设备' group by type2,equipment


END --CREATE PROCEDURE
