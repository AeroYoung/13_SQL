-- =============================================
-- Author:		杨尧
-- Create date: 2016-10-01
-- Description:	重命名工序模板
-- =============================================
if OBJECT_ID(N'dbo.RenameProcessTemp', N'P') is NOT null 
DROP procedure  RenameProcessTemp 
GO
CREATE PROCEDURE RenameProcessTemp
	@newTempName varchar(MAX) = '',
	@oldTempName varchar(MAX) = ''
AS
BEGIN
	if(@newTempName<>@oldTempName)
	begin
		return
	end
	else if exists(select tempName from MES_ProcessTempList_table where tempName=@newTempName)	
	begin
		return 
	end
	else
	begin
		update MES_ProcessTempList_table set tempName=@newTempName where tempName=@oldTempName
		update MES_ProcessTempContent_table set tempName=@newTempName where tempName=@oldTempName
	end
END
GO