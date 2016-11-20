-- =============================================
-- Author:		杨尧
-- Create date: 2016-10-18
-- Description:	查询工序模板内容,并用is_basic区分工序是否是标准工序
-- =============================================
if OBJECT_ID(N'dbo.JointQueryProcessTempContent', N'P') is NOT null 
DROP procedure  JointQueryProcessTempContent 
GO
CREATE PROCEDURE JointQueryProcessTempContent 
	@tempName varchar(MAX)=''
AS
BEGIN
	select tempName,processID,processName,processContent,preTime,singleTime,machine,outSourcing,
	is_basic=case
		when processName in (select processName from MES_BasicProcess_table) THEN 1
		ELSE 0
		END
	from MES_ProcessTempContent_table where tempName=@tempName 
	
	order by processID
END
GO
