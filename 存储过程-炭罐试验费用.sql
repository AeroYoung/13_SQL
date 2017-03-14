-- =============================================
-- Author:		��Ң
-- Create date: 2017-03-14
-- Description:	�������ͳ��
-- =============================================
if OBJECT_ID(N'dbo.CanisterCostStatistic', N'P') is NOT null 
DROP procedure  CanisterCostStatistic 
GO

CREATE PROCEDURE CanisterCostStatistic
	@beginDate varchar(MAX) = '2017/06/01',--��ʼ����
	@endDate varchar(MAX) = '2018/01/01',--��������
	@merge bit = 1, -- �Ƿ�ϲ�N�¹���
	@groupString VARCHAR(MAX) = 'SHED,taskType',--GROUP BY
	@queryString VARCHAR(MAX) = ' where billCheck=''��'''--��ѯ����
AS
BEGIN
--1 ��������

	select cast(year(receiveDate) as varchar)+'��' as y,cast(month(receiveDate) as varchar)+'��' as m,* 
		into #data from CanisterDataTable WHERE receiveDate BETWEEN @beginDate AND @endDate
	
	if (@merge=1) --��N�¹���ϲ�
	begin
		update #data set taskType='����' where taskType like '����'
	end

	--2 ��ѯ
	declare @strSql VARCHAR(MAX)

	SET @strSql = 'SELECT sum(cast(cost as float)) AS COST,count(*) AS NUM,'+@groupString+' FROM #data '
	set @strSql += @queryString
	set @strSql += ' GROUP BY '+@groupString

	EXEC(@strSql)

END