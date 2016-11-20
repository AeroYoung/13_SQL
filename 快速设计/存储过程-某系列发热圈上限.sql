-- =============================================
-- Author:		杨尧
-- Create date: 2016-11-12
-- Description:	某系列发热圈上限
-- =============================================
if OBJECT_ID(N'dbo.HeaterUpperLimit', N'P') is NOT null 
DROP procedure  HeaterUpperLimit 
GO
CREATE PROCEDURE HeaterUpperLimit
	@series varchar(MAX) = ''
AS
BEGIN
	SELECT MAX(M)AS EXPR1 FROM( 
		select MAX(Z1) AS M  FROM standard_nozzle_length_table WHERE series=@series
		union ALL select MAX(Z2) AS M  FROM standard_nozzle_length_table WHERE series=@series 
		union ALL select MAX(Z3) AS M  FROM standard_nozzle_length_table WHERE series=@series
		) EXPR2
END
GO
