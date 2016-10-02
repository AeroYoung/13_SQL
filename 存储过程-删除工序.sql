-- =============================================
-- Author:		ÑîÒ¢
-- Create date: 2016-10-01
-- Description:	É¾³ý¹¤Ðò 
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
