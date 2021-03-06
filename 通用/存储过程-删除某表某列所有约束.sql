--删除table中column的所有约束
if OBJECT_ID(N'dbo.DropColConstraint', N'P') is not null  
    drop procedure dbo.DropColConstraint  
go   
create procedure dbo.DropColConstraint  
    @TableName  NVARCHAR(128),  
    @ColumnName NVARCHAR(128)      
as  
begin  
    if OBJECT_ID(N'#t', N'TB') is not null  
        drop table #t  
      
    -- 查询主键约束、非空约束等  
    select ROW_NUMBER() over(order by CONSTRAINT_NAME) id, CONSTRAINT_NAME into #t from INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE where TABLE_CATALOG=DB_NAME()  
        and TABLE_NAME=@TableName and COLUMN_NAME=@ColumnName  
          
    -- 查询默认值约束  
    declare @cdefault int, @cname varchar(128)  
    select @cdefault=cdefault from sys.syscolumns where name=@ColumnName and id=OBJECT_ID(@TableName) 
              
    select @cname=name from sys.sysobjects where id=@cdefault  
    if @cname is not null  
        insert into #t select coalesce(max(id), 0)+1, @cname from #t      
  
    declare @i int, @imax int  
    select @i=1, @imax=max(id) from #t  
  
    while @i <= @imax  
    begin  
        select @cname=CONSTRAINT_NAME from #t where id=@i  
        exec('alter table ' + @tablename + ' drop constraint ' + @cname)  
        set @i = @i + 1   
    end  
  
    drop table #t  
  
end  
