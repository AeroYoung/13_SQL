-- =============================================
-- Author:		杨尧
-- Create date: 2016-11-12
-- Description:	发热圈长度取整
-- =============================================
if OBJECT_ID(N'dbo.HeaterLenRound', N'P') is NOT null 
DROP procedure  HeaterLenRound 
GO
CREATE PROCEDURE HeaterLenRound
	@series varchar(MAX) = '16',
	@len float = 65
AS
BEGIN
	SELECT top 1 convert(float,SUBSTRING(st_code,11, 3)) as EXPR1 
	FROM (
	select * from standard_table where SUBSTRING(st_code,1,4)='HR82' and Series=@series ) expr2 
		WHERE convert(float,SUBSTRING(st_code,11, 3))<= @len 
		order by convert(float,SUBSTRING(st_code,11, 3)) desc
		    
END
GO
