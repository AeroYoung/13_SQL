-- =============================================
-- Author:		��Ң
-- Create date: 2016-10-01
-- Description:	ɾ������ 
-- =============================================
if OBJECT_ID(N'dbo.DeleteProcessByName', N'P') is NOT null 
DROP procedure  DeleteProcessByName 
GO
CREATE PROCEDURE DeleteProcessByName
	@processName varchar(MAX) = ''
AS
BEGIN
	delete MES_BasicProcess_table where processName=@processName
    delete Map_ProcessMachine_table where process=@processName
END
GO
