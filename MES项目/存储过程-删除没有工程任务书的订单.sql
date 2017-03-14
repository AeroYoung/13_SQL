-- =============================================
-- Author:		杨尧
-- Create date: 2016-09-30
-- Description:	删除没有工程任务书的订单
-- =============================================
if OBJECT_ID(N'dbo.DeleteOrderWithoutTaskDocument', N'P') is NOT null 
DROP procedure  DeleteOrderWithoutTaskDocument 
GO
CREATE PROCEDURE DeleteOrderWithoutTaskDocument 
AS
BEGIN
	delete OA_Order_table WHERE order_id not in (select order_id from OA_Status_table WHERE process_id='task_document')
delete BOM_EXCEL_Table WHERE system_code not in (select order_id from OA_Status_table WHERE process_id='task_document')
delete OA_Status_table WHERE order_id not in (select order_id from OA_Status_table WHERE process_id='task_document')
delete MES_ProcessBOM_table where BOM_ID not in (select ID from BOM_EXCEL_table)
END
GO
