-- =============================================
-- Author:		杨尧
-- Create date: 2016-10-01
-- Description:	工序模板另存为新模板
-- =============================================
if OBJECT_ID(N'dbo.ProcessTempSaveAsNewTemp', N'P') is NOT null 
DROP procedure  ProcessTempSaveAsNewTemp 
GO
CREATE PROCEDURE ProcessTempSaveAsNewTemp
	@newTempName varchar(MAX) = '',
	@oldTempName varchar(MAX) = ''	
AS
BEGIN
	if exists(select tempName from MES_ProcessTempList_table where tempName=@newTempName)	
	begin
		return 
	end
	
    insert into MES_ProcessTempList_table(tempName,tempCode,[readOnly]) 
    select @newTempName as tempName,tempCode,[readOnly] from MES_ProcessTempList_table where tempName=@oldTempName

	insert into MES_ProcessTempContent_table([tempName]
      ,[processID]
      ,[processName]
      ,[processContent]
      ,[preTime]
      ,[singleTime]
      ,[outSourcing]
      ,[machine]
      ,[remark]) 
    select @newTempName as tempName,[processID]
      ,[processName]
      ,[processContent]
      ,[preTime]
      ,[singleTime]
      ,[outSourcing]
      ,[machine]
      ,[remark] from MES_ProcessTempContent_table where tempName=@oldTempName
END
GO
