-- =============================================
-- Author:		��Ң
-- Create date: 2016-09-30
-- Description:	����ϵͳ��ɾ��һ��������������Ϣ
-- =============================================
if OBJECT_ID(N'dbo.DeleteOrderBySystemCode', N'P') is NOT null 
DROP procedure  DeleteOrderBySystemCode 
GO
CREATE PROCEDURE DeleteOrderBySystemCode 
	@systemCODE VARCHAR(MAX) = ''
AS
BEGIN
	delete BOM_EXCEL_Table WHERE system_code=@systemCODE
	delete OA_Order_table WHERE system_code=@systemCODE
	delete OA_Status_table WHERE order_id=@systemCODE 
	delete MES_ProcessBOM_table where BOM_ID not in (select ID from BOM_EXCEL_table)
END
GO
