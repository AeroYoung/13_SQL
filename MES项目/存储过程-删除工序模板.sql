-- =============================================
-- Author:		ÑîÒ¢
-- Create date: 2016-10-01
-- Description:	É¾³ý¹¤ÐòÄ£°å
-- =============================================
if OBJECT_ID(N'dbo.DeleteProcessTempByName', N'P') is NOT null 
DROP procedure  DeleteProcessTempByName 
GO
CREATE PROCEDURE DeleteProcessTempByName
	@tempName varchar(MAX) = ''
AS
BEGIN
	delete MES_ProcessTempList_table where tempName=@tempName
    delete MES_ProcessTempContent_table where tempName=@tempName
END
GO
