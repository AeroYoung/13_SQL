-- =============================================
-- Author:		杨尧
-- Create date: 2016-10-02
-- Description:	向PBOM插入分流板工序模板
-- =============================================
if OBJECT_ID(N'dbo.AddManifoldProcessTemp2PBOM', N'P') is NOT null 
DROP procedure  AddManifoldProcessTemp2PBOM 
GO
CREATE PROCEDURE AddManifoldProcessTemp2PBOM 
	@ID int = 0,
	@tempName varchar(MAX) = '分流板-针阀分体式'
AS
BEGIN
  INSERT INTO MES_ProcessBOM_table
  (BOM_ID,processName,processID,processContent,preTime,singleTime,outSourcing,availMachine)    
  select @ID,processName,processID,processContent,preTime,singleTime,outSourcing,machine
  from MES_ProcessTempContent_table
  where tempName=@tempName order by processID
END
GO