-- =============================================
-- Author:		杨尧
-- Create date: 2016-10-08
-- Description:	清空订单数据
-- =============================================
if OBJECT_ID(N'dbo.TruncateAllOrder', N'P') is NOT null 
DROP procedure  TruncateAllOrder 
GO
CREATE PROCEDURE TruncateAllOrder
	@input int=0
AS
BEGIN
if @input=1
begin
	truncate table BOM_EXCEL_Table 
	truncate table OA_Order_table 
	truncate table OA_Status_table
	truncate table MES_ProcessBOM_table 
end	
END
GO
