-- =============================================
-- Author:		杨尧
-- Create date: 2016-09-30
-- Description:	根据系统号删除一个订单的所有信息
-- =============================================
if OBJECT_ID(N'dbo.DeleteOrderBySystemCode', N'P') is NOT null 
DROP procedure  DeleteOrderBySystemCode 
GO
CREATE PROCEDURE DeleteOrderBySystemCode 
	@systemCODE VARCHAR(MAX) = ''
AS
BEGIN
	delete MES_ProcessBOM_table where BOM_ID IN (select ID from BOM_EXCEL_Table WHERE system_code=@systemCODE)
	delete BOM_EXCEL_Table WHERE system_code=@systemCODE
	delete OA_Order_table WHERE system_code=@systemCODE
	delete OA_Status_table WHERE order_id=@systemCODE 
END
GO
