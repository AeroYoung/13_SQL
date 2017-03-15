-- =============================================
-- Author:		��Ң
-- Create date: 2017-03-14
-- Description:	�������ͳ��
-- =============================================
if OBJECT_ID(N'dbo.VehicleCostStatistic', N'P') is NOT null 
DROP procedure  VehicleCostStatistic 
GO
CREATE PROCEDURE VehicleCostStatistic
	@beginDate varchar(MAX) = '2016/01/01',--��ʼ����
	@endDate varchar(MAX) = '2018/01/01',--��������
	@merge bit = 1, -- �Ƿ�ϲ�N�¹���
	@groupString VARCHAR(MAX) = 'SHED,taskType',--GROUP BY
	@yGroup VARCHAR(MAX) = ''
AS
BEGIN
--1 �������ݵ�#data

select cast(year(preStartDate) as varchar)+'��' as y,cast(month(preStartDate) as varchar)+'��' as m,
	SHED,taskType,testType,manufacturer,billCheck,[standard],cost
	into #data from VehicleDataTable WHERE preStartDate BETWEEN @beginDate AND @endDate

update #data set cost=0 where ISNUMERIC(cost)=0
update #data set billCheck='��' where billCheck='1'
update #data set billCheck='��' where billCheck<>'��'

if (@merge=1) --��N�¹���ϲ�
begin
	update #data set taskType='����' where taskType like '����'
	update #data set taskType='����' where taskType like '����'
end

select * from #data --tables[0]

--2 ��ѯ����
DECLARE @strSql VARCHAR(MAX)

if(@yGroup<>'')
BEGIN

	SET @strSql = 'select distinct '+@yGroup+' from #data' --tables[1] -series
	EXEC(@strSql)

	--tables[2] ��C#��ʹ��WHERE�õ�����ֵ
	SET @groupString += ',' + @yGroup
	SET @strSql = 'SELECT sum(cast(cost as float)) AS COST,count(*) AS NUM,'+@groupString+' FROM #data '
	SET @strSql += ' GROUP BY '+@groupString

	EXEC(@strSql)

END --if(@yGroup<>'')
ELSE
BEGIN

	SELECT TOP 1 'ȫ��' AS EXPR1 FROM #data --tables[1] -series
	--tables[2] ��C#��ʹ��WHERE�õ�����ֵ
	SET @strSql = 'SELECT sum(cast(cost as float)) AS COST,count(*) AS NUM,'+@groupString+',''ȫ��'' as yGroup FROM #data '
	SET @strSql += ' GROUP BY '+@groupString

	EXEC(@strSql)
END --if(@yGroup<>'') ELSE

END --PROCEDURE
