-- =============================================
-- Author:		杨尧
-- Create date: 2017-03-14
-- Description:	试验费用统计
-- =============================================
if OBJECT_ID(N'dbo.CanisterCostStatistic', N'P') is NOT null 
DROP procedure  CanisterCostStatistic 
GO

CREATE PROCEDURE CanisterCostStatistic
	@beginDate varchar(MAX) = '2017/06/01',--开始日期
	@endDate varchar(MAX) = '2018/01/01',--结束日期
	@merge bit = 1, -- 是否合并N月公告
	@groupString VARCHAR(MAX) = 'SHED,taskType',--GROUP BY
	@queryString VARCHAR(MAX) = ' where billCheck=''是'''--查询条件
AS
BEGIN
--1 复制数据

	select cast(year(receiveDate) as varchar)+'年' as y,cast(month(receiveDate) as varchar)+'月' as m,* 
		into #data from CanisterDataTable WHERE receiveDate BETWEEN @beginDate AND @endDate
	
	if (@merge=1) --把N月公告合并
	begin
		update #data set taskType='公告' where taskType like '公告'
	end

	--2 查询
	declare @strSql VARCHAR(MAX)

	SET @strSql = 'SELECT sum(cast(cost as float)) AS COST,count(*) AS NUM,'+@groupString+' FROM #data '
	set @strSql += @queryString
	set @strSql += ' GROUP BY '+@groupString

	EXEC(@strSql)

END