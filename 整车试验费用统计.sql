-- =============================================
-- Author:		杨尧
-- Create date: 2017-03-14
-- Description:	试验费用统计
-- =============================================
if OBJECT_ID(N'dbo.VehicleCostStatistic', N'P') is NOT null 
DROP procedure  VehicleCostStatistic 
GO
CREATE PROCEDURE VehicleCostStatistic
	@beginDate varchar(MAX) = '2016/01/01',--开始日期
	@endDate varchar(MAX) = '2018/01/01',--结束日期
	@merge bit = 1, -- 是否合并N月公告
	@groupString VARCHAR(MAX) = 'SHED,taskType',--GROUP BY
	@yGroup VARCHAR(MAX) = ''
AS
BEGIN
--1 复制数据到#data

select cast(year(preStartDate) as varchar)+'年' as y,cast(month(preStartDate) as varchar)+'月' as m,
	SHED,taskType,testType,manufacturer,billCheck,[standard],cost
	into #data from VehicleDataTable WHERE preStartDate BETWEEN @beginDate AND @endDate

update #data set cost=0 where ISNUMERIC(cost)=0
update #data set billCheck='是' where billCheck='1'
update #data set billCheck='否' where billCheck<>'是'

if (@merge=1) --把N月公告合并
begin
	update #data set taskType='公告' where taskType like '公告'
	update #data set taskType='科研' where taskType like '科研'
end

select * from #data --tables[0]

--2 查询条件
DECLARE @strSql VARCHAR(MAX)

if(@yGroup<>'')
BEGIN

	SET @strSql = 'select distinct '+@yGroup+' from #data' --tables[1] -series
	EXEC(@strSql)

	--tables[2] 在C#中使用WHERE得到分组值
	SET @groupString += ',' + @yGroup
	SET @strSql = 'SELECT sum(cast(cost as float)) AS COST,count(*) AS NUM,'+@groupString+' FROM #data '
	SET @strSql += ' GROUP BY '+@groupString

	EXEC(@strSql)

END --if(@yGroup<>'')
ELSE
BEGIN

	SELECT TOP 1 '全部' AS EXPR1 FROM #data --tables[1] -series
	--tables[2] 在C#中使用WHERE得到分组值
	SET @strSql = 'SELECT sum(cast(cost as float)) AS COST,count(*) AS NUM,'+@groupString+',''全部'' as yGroup FROM #data '
	SET @strSql += ' GROUP BY '+@groupString

	EXEC(@strSql)
END --if(@yGroup<>'') ELSE

END --PROCEDURE
