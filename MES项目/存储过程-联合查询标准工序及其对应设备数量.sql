-- =============================================
-- Author:		��Ң
-- Create date: 2016-10-03
-- Description:	��ѯ��׼�������Ӧ���豸������
-- =============================================
if OBJECT_ID(N'dbo.JointQueryBasicProcess', N'P') is NOT null 
DROP procedure  JointQueryBasicProcess 
GO
CREATE PROCEDURE JointQueryBasicProcess 
AS
BEGIN
	SELECT processName,outSourcing,COUNT(*) AS machineNum
	FROM MES_BasicProcess_table,Map_ProcessMachine_table 
	WHERE MES_BasicProcess_table.processName=process
	GROUP BY processName,outSourcing

	union SELECT processName,outSourcing,0 AS machineNum

	FROM MES_BasicProcess_table 
	WHERE MES_BasicProcess_table.processName not in (select distinct process from Map_ProcessMachine_table)
	order by processName,machineNum
END
GO
