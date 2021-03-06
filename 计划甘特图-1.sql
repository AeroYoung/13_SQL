-- =============================================
-- Author:		杨尧
-- Create date: 2017-04-26
-- Description:	计划甘特图
-- =============================================
if OBJECT_ID(N'dbo.PlanGantt1', N'P') is NOT null 
DROP procedure  PlanGantt1 
GO
CREATE PROCEDURE PlanGantt1
	@date1 DATE = '2017-01-1',
	@date2 DATE = '2017-12-31',
	@equipment varchar(50) = 'SHED1'
AS
BEGIN

select *,0 as d1,1 as d2 into #temp from GanttTable where DATEDIFF(D,@date1,endDate)>=0 AND DATEDIFF(D,@date2,startDate)<=0 AND equipment=@equipment

declare @minDate as date = @date1
declare @maxDate as date = @date2
--set @minDate =( select MIN(startDate) from #temp )
--set @maxDate =( select MAX(endDate) from #temp )
set @minDate = DATEADD(wk,DATEDIFF(wk,0,@minDate),0) --DATEADD(wk, DATEDIFF(wk,0,DATEADD(dd, -7, @minDate)), 0)
set @maxDate = (SELECT DATEADD(wk, DATEDIFF(wk,0,DATEADD(dd, -1, @maxDate)), 6))

--1. RETURN 最早的周一和最后的周日
select @minDate,@maxDate

update #temp set d1=DATEDIFF(D,@minDate,startDate), d2=DATEDIFF(D,@minDate,endDate)
--select * from #temp

END --CREATE PROCEDURE
