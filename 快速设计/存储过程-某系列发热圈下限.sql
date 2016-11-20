-- =============================================
-- Author:		杨尧
-- Create date: 2016-11-12
-- Description:	某系列发热圈下限
-- =============================================
if OBJECT_ID(N'dbo.HeaterLowerLimit', N'P') is NOT null 
DROP procedure  HeaterLowerLimit 
GO
CREATE PROCEDURE HeaterLowerLimit
	@series varchar(MAX) = ''
AS
BEGIN
	SELECT MIN(M)AS EXPR1 FROM( 
		select MIN(Z1) AS M  FROM standard_nozzle_length_table WHERE series=@series and  Z1!=0
		union ALL select MIN(Z2) AS M  FROM standard_nozzle_length_table WHERE series=@series and  Z2!=0
		union ALL select MIN(Z3) AS M  FROM standard_nozzle_length_table WHERE series=@series and  Z3!=0
		) EXPR2
END
GO
