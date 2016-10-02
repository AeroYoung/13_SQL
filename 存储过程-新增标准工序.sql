-- =============================================
-- Author:		杨尧
-- Create date: 2016-10-02
-- Description:	新增标准工序
-- =============================================
if OBJECT_ID(N'dbo.InsertNewBasicProcess', N'P') is NOT null 
DROP procedure  InsertNewBasicProcess 
go
CREATE PROCEDURE InsertNewBasicProcess 
	@processName varchar(MAX) = ''
AS
BEGIN
	insert into MES_BasicProcess_table(processName,outSourcing) values(@processName,0)
END
GO