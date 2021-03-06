-- =============================================
-- Author:		杨尧
-- Create date: 2017-03-23 
-- Description:	自定义统计-数值型-作为并列柱状图 DataTable作为参数
-- =============================================
if OBJECT_ID(N'dbo.CustomNumericalStatistic1', N'P') is NOT null 
DROP procedure  CustomNumericalStatistic1 
GO
CREATE PROCEDURE CustomNumericalStatistic1
	@CustomData CustomStatistic READONLY
AS
BEGIN

select * into #data from @CustomData

BEGIN --1 检查格式

	update #data set X='其它' where X is null or X=''
	update #data set Y1='0' where ISNUMERIC(Y1)=0
	update #data set Y2='0' where ISNUMERIC(Y1)=0
	update #data set Y3='0' where ISNUMERIC(Y1)=0
	update #data set Y4='0' where ISNUMERIC(Y1)=0
	update #data set Y5='0' where ISNUMERIC(Y1)=0

END

DECLARE @argCount int --distinct X 的数量
SET @argCount = (SELECT COUNT(DISTINCT X) FROM #data)

--tables[0] 和
select X as arg,
SUM(cast(Y1 as float)) as value1,SUM(cast(Y2 as float)) as value2,SUM(cast(Y3 as float)) as value3,
SUM(cast(Y4 as float)) as value4,SUM(cast(Y5 as float)) as value5 FROM #data GROUP BY X

--tables[1] 均值
select X as arg,
AVG(cast(Y1 as float)) as value1,AVG(cast(Y2 as float)) as value2,AVG(cast(Y3 as float)) as value3,
AVG(cast(Y4 as float)) as value4,AVG(cast(Y5 as float)) as value5 FROM #data GROUP BY X

END --CREATE PROCEDURE
