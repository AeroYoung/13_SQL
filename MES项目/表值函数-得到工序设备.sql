-- =============================================
-- Author:		��Ң
-- Create date: 2016-10-05
-- Description:	������˿�ͺźͳ��ȣ��õ���ͷ��˿��Assembly_id
-- =============================================
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[QD_GetBoltAssemblyID]') 
	and xtype in (N'FN', N'IF', N'TF'))
Drop Function QD_GetBoltAssemblyID
GO
CREATE FUNCTION QD_GetBoltAssemblyID
(
	@boltM int = 10,--M8 M10 M12
	@boltL float = 25 --��˿����
)
RETURNS varchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @assemblyID varchar(MAX) = '�Ǳ걭ͷ��˿'
	Declare @temp table(assembly_id varchar(max),L float)
	declare @i int
	
	set @i = 1;
	
	insert into @temp(assembly_id,L) 
	select top 1 assembly_id,CAST(SUBSTRING(part_code,11,3) as int) AS L from assembly_table 
	where component_name='��ͷ��˿' and SUBSTRING(part_code,1,2)='HB'
	AND CAST(SUBSTRING(part_code,6,2) as int)=@boltM
	AND CAST(SUBSTRING(part_code,11,3) as int)>=@boltL ORDER BY L

	while(@i <= (select COUNT(1) from @temp))
	begin
		select  @assemblyID = assembly_id from @temp
		set @i = @i + 1;
	end

	-- Return the result of the function
	RETURN @assemblyID

END
GO

