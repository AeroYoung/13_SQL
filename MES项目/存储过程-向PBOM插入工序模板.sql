-- =============================================
-- Author:		杨尧
-- Create date: 2016-09-30
-- Description:	向PBOM插入工序模板(除了分流板)
-- =============================================
if OBJECT_ID(N'dbo.AddProcessTemp2PBOM', N'P') is NOT null 
DROP procedure  AddProcessTemp2PBOM 
GO
CREATE PROCEDURE AddProcessTemp2PBOM 
	@systemCode varchar(MAX) = ''
AS
BEGIN

  delete MES_ProcessBOM_table WHERE BOM_ID in (select ID from BOM_EXCEL_Table WHERE system_code=@systemCode
	 and code<>'40301')

  INSERT INTO MES_ProcessBOM_table
  (BOM_ID,processName,processID,processContent,preTime,singleTime,outSourcing,availMachine)    
  select ID,processName,processID,processContent,preTime,singleTime,outSourcing,machine
  from BOM_EXCEL_table,MES_ProcessTempContent_table,Map_ProcessTempStandard_table,MES_ProcessTempList_table
  where 
  BOM_EXCEL_Table.code=Map_ProcessTempStandard_table.code 
  and MES_ProcessTempList_table.tempName=Map_ProcessTempStandard_table.tempName 
  AND MES_ProcessTempContent_table.tempName=Map_ProcessTempStandard_table.tempName
  AND (manufacture_type='二次加工' or manufacture_type='非标')
  AND system_code=@systemCode
  and MES_ProcessTempList_table.[readOnly]<>1
  
END
GO
