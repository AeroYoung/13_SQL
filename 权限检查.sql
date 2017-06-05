-- =============================================
-- Author:		杨尧
-- Create date: 2017-05-02
-- Description:	根据用户ID、模块名和功能名称检查该用户是否有权限
-- =============================================
if OBJECT_ID(N'dbo.AuthorityCheck', N'P') is NOT null 
DROP procedure  AuthorityCheck 
GO
CREATE procedure AuthorityCheck
(
	@userID varchar(MAX)='',
	@module varchar(MAX)='',
	@operate varchar(MAX)=''
)
AS
BEGIN
	select count(*) from AuthorityRoleTable,AuthorityTable,UserTable
		where 
		AuthorityTable.ID = AuthorityRoleTable.authorityID and
		AuthorityRoleTable.roleName = UserTable.role and		
		UserTable.userID = @userID AND		
		AuthorityTable.module = @module and
		AuthorityTable.operate = @operate 
END
GO

