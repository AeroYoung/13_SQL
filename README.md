# 13_SQL
项目过程中积累的SQL文件

更新：
* 存储过程-删除某表某列
* 清空订单

删除了默认数据库后SQL2008无法登陆：
在cmd中执行：osql /U"sa" /P"sa的密码" /d"master" /Q"exec sp_defaultdb N'sa', N'master'"
将默认数据库改回master即可