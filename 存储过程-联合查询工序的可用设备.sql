-- =============================================
-- Author:		��Ң
-- Create date: 2016-10-02
-- Description:	���ϲ�ѯ-ĳ��������п����豸
-- =============================================
if OBJECT_ID(N'dbo.JointQueryAvailMachine', N'P') is NOT null 
DROP procedure  JointQueryAvailMachine 
go
CREATE PROCEDURE JointQueryAvailMachine 
	@processName varchar(MAX) = ''
AS
BEGIN
	SELECT * from MES_Machine_table,MES_BasicProcess_table,Map_ProcessMachine_table where
	MES_Machine_table.machineID=machine and processName=process and process=@processName
END
GO
