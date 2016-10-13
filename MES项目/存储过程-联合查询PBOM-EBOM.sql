-- =============================================
-- Author:		<杨尧>
-- Create date: <2016-09-30>
-- Description:	<联合查询BOM_EXCEL和ProcessBOM>
-- =============================================
if OBJECT_ID(N'dbo.JointQueryEBOM_PBOM', N'P') is NOT null 
DROP procedure  JointQueryEBOM_PBOM 
go
CREATE PROCEDURE JointQueryEBOM_PBOM
		-- Add the parameters for the stored procedure here
		@systemCode varchar(MAX) = ''
	AS
BEGIN
	select  system_code,ID,name,code,num,specification,manufacture_type,remark
	,group_code,COUNT(*) AS processNum from MES_ProcessBOM_view
	where system_code=@systemCode 
	group by system_code,ID,name,code,num,specification,manufacture_type,remark,group_code
	
	UNION ALL 

	select system_code,ID,name,code,num,specification,manufacture_type,remark,group_code,0 AS processNum
	from BOM_EXCEL_table WHERE system_code=@systemCode AND
	ID not in (select BOM_ID from MES_ProcessBom_table)

	order by manufacture_type,processNum desc
END
GO
