-- =============================================
-- Author:		��Ң
-- Create date: 2017-05-02
-- Description:	�����û�ID��ģ�����͹������Ƽ����û��Ƿ���Ȩ��
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

