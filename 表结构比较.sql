if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_sql_sjkbj]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_sql_sjkbj]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE proc p_sql_sjkbj
@dbname1 varchar(250), --要比较的数据库名1
@dbname2 varchar(250)  --要比较的数据库名2
as
create table #tb1(表名1 varchar(250),字段名 varchar(250),序号 int,标识 bit,主键 bit,类型 varchar(250),
占用字节数 int,长度 int,小数位数 int,允许空 bit,默认值 varchar(500),字段说明 varchar(500))
create table #tb2(表名2 varchar(250),字段名 varchar(250),序号 int,标识 bit,主键 bit,类型 varchar(250),
占用字节数 int,长度 int,小数位数 int,允许空 bit,默认值 varchar(500),字段说明 varchar(500))
--得到数据库1的结构
exec('insert into #tb1 SELECT 
       表名=d.name,字段名=a.name,序号=a.colid,
       标识=case when a.status=0x80 then 1 else 0 end,
       主键=case when exists(SELECT 1 FROM '+@dbname1+'..sysobjects where xtype=''PK'' and name in (
                                      SELECT name FROM '+@dbname1+'..sysindexes WHERE indid in(
                                      SELECT indid FROM '+@dbname1+'..sysindexkeys WHERE id = a.id AND colid=a.colid
                           ))) then 1 else 0 end,
       类型=b.name, 占用字节数=a.length,长度=a.prec,小数位数=a.scale, 允许空=a.isnullable,
       默认值=isnull(e.text,''''''),字段说明=isnull(g.[value],'''''')
       FROM '+@dbname1+'..syscolumns a
       left join '+@dbname1+'..systypes b on a.xtype=b.xusertype
       inner join '+@dbname1+'..sysobjects d on a.id=d.id  and d.xtype=''U'' and  d.name<>''dtproperties''
       left join '+@dbname1+'..syscomments e on a.cdefault=e.id
       left join '+@dbname1+'..sysproperties g on a.id=g.id and a.colid=g.smallid  
       order by a.id,a.colorder')

--得到数据库2的结构
exec('insert into #tb2 SELECT 
        表名=d.name,字段名=a.name,序号=a.colid,
        标识=case when a.status=0x80 then 1 else 0 end,
        主键=case when exists(SELECT 1 FROM '+@dbname2+'..sysobjects where xtype=''PK'' and name in (
        SELECT name FROM '+@dbname2+'..sysindexes WHERE indid in(
        SELECT indid FROM '+@dbname2+'..sysindexkeys WHERE id = a.id AND colid=a.colid
        ))) then 1 else 0 end,
        类型=b.name, 占用字节数=a.length,长度=a.prec,小数位数=a.scale, 允许空=a.isnullable,
        默认值=isnull(e.text,''''''),字段说明=isnull(g.[value],'''''')
       FROM '+@dbname2+'..syscolumns a
       left join '+@dbname2+'..systypes b on a.xtype=b.xusertype
       inner join '+@dbname2+'..sysobjects d on a.id=d.id  and d.xtype=''U'' and  d.name<>''dtproperties''
       left join '+@dbname2+'..syscomments e on a.cdefault=e.id
       left join '+@dbname2+'..sysproperties g on a.id=g.id and a.colid=g.smallid  
       order by a.id,a.colorder')
--and not exists(select 1 from #tb2 where 表名2=a.表名1)
select 比较结果=case when a.表名1 is null and b.序号=1 then '库1缺少表：'+b.表名2
         when b.表名2 is null and a.序号=1 then '库2缺少表:'+a.表名1
         when a.字段名 is null and exists(select 1 from #tb1 where 表名1=b.表名2) then '库1 ['+b.表名2+'] 缺少字段：'+b.字段名
         when b.字段名 is null and exists(select 1 from #tb2 where 表名2=a.表名1) then '库2 ['+a.表名1+'] 缺少字段：'+a.字段名
        when a.标识<>b.标识 then '标识不同'
        when a.主键<>b.主键 then '主键设置不同'
        when a.类型<>b.类型 then '字段类型不同'
        when a.占用字节数<>b.占用字节数 then '占用字节数'
        when a.长度<>b.长度 then '长度不同'
        when a.小数位数<>b.小数位数 then '小数位数不同'
        when a.允许空<>b.允许空 then '是否允许空不同'
        when a.默认值<>b.默认值 then '默认值不同'
        when a.字段说明<>b.字段说明 then '字段说明不同'
 else '' end,
        *
        from #tb1 a
        full join #tb2 b on a.表名1=b.表名2 and a.字段名=b.字段名
        where a.表名1 is null or a.字段名 is null or b.表名2 is null or b.字段名 is null 
                  or a.标识<>b.标识 or a.主键<>b.主键 or a.类型<>b.类型
                  or a.占用字节数<>b.占用字节数 or a.长度<>b.长度 or a.小数位数<>b.小数位数
                  or a.允许空<>b.允许空 or a.默认值<>b.默认值 or a.字段说明<>b.字段说明
                  order by isnull(a.表名1,b.表名2),isnull(a.序号,b.序号)--isnull(a.字段名,b.字段名)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

