-- =============================================
-- Author:		��Ң
-- Create date: 2016-10-01
-- Description:	ɾ������ģ��
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
