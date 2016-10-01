SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		��Ң
-- Create date: 2016-09-30
-- Description:	����ϵͳ��ɾ��һ��������������Ϣ
-- =============================================
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
