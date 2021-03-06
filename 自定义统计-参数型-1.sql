-- =============================================
-- Author:		杨尧
-- Create date: 2017-03-22 
-- Description:	自定义统计-参数型-作为并列柱状图 DataTable作为参数
-- =============================================
if OBJECT_ID(N'dbo.CustomParameterStatistic1', N'P') is NOT null 
DROP procedure  CustomParameterStatistic1 
GO
CREATE PROCEDURE CustomParameterStatistic1
	@CustomData CustomStatistic READONLY,
	@type int = 1 --0 只有X轴,则以数量为Y轴 其它有X轴和Y轴
AS
BEGIN

--tables[0] 参数统计
select * into #data0 from @CustomData

update #data0 set X='其它' where X is null or X=''
update #data0 set Y1='其它' where Y1 is null or Y1=''

if(@type=0) --只有X轴
begin
	select X AS arg,'数量' as series,COUNT(*) AS value FROM #data0 group by X
	select '数量' as series
end
else
begin
	select X AS arg,Y1 as series,COUNT(*) AS value FROM #data0 group by X,Y1 --points
	select distinct Y1 AS series from #data0 order by Y1 --series
end


END --CREATE PROCEDURE
