-- =============================================
-- Author:		杨尧
-- Create date: 2016-10-03
-- Description:	查询标准工序及其对应的设备的数量
-- =============================================
if OBJECT_ID(N'dbo.JointQeryBasicProcess', N'P') is NOT null 
DROP procedure  JointQeryBasicProcess 
GO
CREATE PROCEDURE JointQeryBasicProcess 
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
