if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_sql_sjkbj]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_sql_sjkbj]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE proc p_sql_sjkbj
@dbname1 varchar(250), --Ҫ�Ƚϵ����ݿ���1
@dbname2 varchar(250)  --Ҫ�Ƚϵ����ݿ���2
as
create table #tb1(����1 varchar(250),�ֶ��� varchar(250),��� int,��ʶ bit,���� bit,���� varchar(250),
ռ���ֽ��� int,���� int,С��λ�� int,����� bit,Ĭ��ֵ varchar(500),�ֶ�˵�� varchar(500))
create table #tb2(����2 varchar(250),�ֶ��� varchar(250),��� int,��ʶ bit,���� bit,���� varchar(250),
ռ���ֽ��� int,���� int,С��λ�� int,����� bit,Ĭ��ֵ varchar(500),�ֶ�˵�� varchar(500))
--�õ����ݿ�1�Ľṹ
exec('insert into #tb1 SELECT 
       ����=d.name,�ֶ���=a.name,���=a.colid,
       ��ʶ=case when a.status=0x80 then 1 else 0 end,
       ����=case when exists(SELECT 1 FROM '+@dbname1+'..sysobjects where xtype=''PK'' and name in (
                                      SELECT name FROM '+@dbname1+'..sysindexes WHERE indid in(
                                      SELECT indid FROM '+@dbname1+'..sysindexkeys WHERE id = a.id AND colid=a.colid
                           ))) then 1 else 0 end,
       ����=b.name, ռ���ֽ���=a.length,����=a.prec,С��λ��=a.scale, �����=a.isnullable,
       Ĭ��ֵ=isnull(e.text,''''''),�ֶ�˵��=isnull(g.[value],'''''')
       FROM '+@dbname1+'..syscolumns a
       left join '+@dbname1+'..systypes b on a.xtype=b.xusertype
       inner join '+@dbname1+'..sysobjects d on a.id=d.id  and d.xtype=''U'' and  d.name<>''dtproperties''
       left join '+@dbname1+'..syscomments e on a.cdefault=e.id
       left join '+@dbname1+'..sysproperties g on a.id=g.id and a.colid=g.smallid  
       order by a.id,a.colorder')

--�õ����ݿ�2�Ľṹ
exec('insert into #tb2 SELECT 
        ����=d.name,�ֶ���=a.name,���=a.colid,
        ��ʶ=case when a.status=0x80 then 1 else 0 end,
        ����=case when exists(SELECT 1 FROM '+@dbname2+'..sysobjects where xtype=''PK'' and name in (
        SELECT name FROM '+@dbname2+'..sysindexes WHERE indid in(
        SELECT indid FROM '+@dbname2+'..sysindexkeys WHERE id = a.id AND colid=a.colid
        ))) then 1 else 0 end,
        ����=b.name, ռ���ֽ���=a.length,����=a.prec,С��λ��=a.scale, �����=a.isnullable,
        Ĭ��ֵ=isnull(e.text,''''''),�ֶ�˵��=isnull(g.[value],'''''')
       FROM '+@dbname2+'..syscolumns a
       left join '+@dbname2+'..systypes b on a.xtype=b.xusertype
       inner join '+@dbname2+'..sysobjects d on a.id=d.id  and d.xtype=''U'' and  d.name<>''dtproperties''
       left join '+@dbname2+'..syscomments e on a.cdefault=e.id
       left join '+@dbname2+'..sysproperties g on a.id=g.id and a.colid=g.smallid  
       order by a.id,a.colorder')
--and not exists(select 1 from #tb2 where ����2=a.����1)
select �ȽϽ��=case when a.����1 is null and b.���=1 then '��1ȱ�ٱ�'+b.����2
         when b.����2 is null and a.���=1 then '��2ȱ�ٱ�:'+a.����1
         when a.�ֶ��� is null and exists(select 1 from #tb1 where ����1=b.����2) then '��1 ['+b.����2+'] ȱ���ֶΣ�'+b.�ֶ���
         when b.�ֶ��� is null and exists(select 1 from #tb2 where ����2=a.����1) then '��2 ['+a.����1+'] ȱ���ֶΣ�'+a.�ֶ���
        when a.��ʶ<>b.��ʶ then '��ʶ��ͬ'
        when a.����<>b.���� then '�������ò�ͬ'
        when a.����<>b.���� then '�ֶ����Ͳ�ͬ'
        when a.ռ���ֽ���<>b.ռ���ֽ��� then 'ռ���ֽ���'
        when a.����<>b.���� then '���Ȳ�ͬ'
        when a.С��λ��<>b.С��λ�� then 'С��λ����ͬ'
        when a.�����<>b.����� then '�Ƿ�����ղ�ͬ'
        when a.Ĭ��ֵ<>b.Ĭ��ֵ then 'Ĭ��ֵ��ͬ'
        when a.�ֶ�˵��<>b.�ֶ�˵�� then '�ֶ�˵����ͬ'
 else '' end,
        *
        from #tb1 a
        full join #tb2 b on a.����1=b.����2 and a.�ֶ���=b.�ֶ���
        where a.����1 is null or a.�ֶ��� is null or b.����2 is null or b.�ֶ��� is null 
                  or a.��ʶ<>b.��ʶ or a.����<>b.���� or a.����<>b.����
                  or a.ռ���ֽ���<>b.ռ���ֽ��� or a.����<>b.���� or a.С��λ��<>b.С��λ��
                  or a.�����<>b.����� or a.Ĭ��ֵ<>b.Ĭ��ֵ or a.�ֶ�˵��<>b.�ֶ�˵��
                  order by isnull(a.����1,b.����2),isnull(a.���,b.���)--isnull(a.�ֶ���,b.�ֶ���)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

