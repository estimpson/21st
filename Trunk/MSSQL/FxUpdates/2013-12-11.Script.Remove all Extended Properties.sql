/* Added capture for Index and functions ep. Also Functionality added to Adam's script in order to verify the given property exists prior to deletion along with creation scripts

Antoine Peterson

13/11/2013*/

/*Are there any extended properties? Let's take a look*/

select
    *
,   object_name(major_id)
from
    sys.extended_properties xp

/*Now let's generate sp_dropextendedproperty statements for all of them.*/

--tables

set nocount on;

select
    sep.Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max)) + '],

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''table''

,@level1name = ''' + object_name(sep.major_id) + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''table''

,@level1name = ''' + object_name(sep.major_id) + '''' + '

END

'
from
    sys.extended_properties sep
    join sys.tables t
        on sep.major_id = t.object_id
where
    sep.class_desc = 'OBJECT_OR_COLUMN'
    and sep.minor_id = 0
union

--columns
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max)) + '],

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''table''

,@level1name = ''' + object_name(sep.major_id) + '''

,@level2type = ''column''

,@level2name = ''' + columns.name + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''table''

,@level1name = ''' + object_name(sep.major_id) + '''

,@level2type = ''column''

,@level2name = ''' + columns.name + '''' + '

END

'
from
    sys.extended_properties as sep
    join sys.columns
        on columns.object_id = sep.major_id
           and columns.column_id = sep.minor_id
where
    sep.class_desc = 'OBJECT_OR_COLUMN'
    and sep.minor_id > 0
union

-- Indexes
select
    sep.major_id
,   sep.minor_id
,   sep.name
,   sep.value as Value
,   'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(sep.major_id as nvarchar(max))
    + '  AND [name] = ''' + sep.name + ''' AND [minor_id] =  ' + cast(sep.minor_id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(sep.value as nvarchar(max)) + '],

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''table''

,@level1name = ''' + object_name(sep.major_id) + '''

,@level2type = ''index''

,@level2name = ''' + sys.indexes.name + '''' + '

End ' as CreateScript
,   'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(sep.major_id as nvarchar(max))
    + '  AND [name] = ''' + sep.name + ''' AND [minor_id] =  ' + cast(sep.minor_id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''table''

,@level1name = ''' + object_name(sep.major_id) + '''

,@level2type = ''index''

,@level2name = ''' + sys.indexes.name + '''' + '

END

' as DropScript
from
    sys.extended_properties as sep
    inner join sys.indexes
        on sys.indexes.object_id = sep.major_id
           and sys.indexes.index_id = sep.minor_id
where
    (sep.class_desc in ('OBJECT_OR_COLUMN', 'INDEX'))
    and (sep.minor_id > 0)
union

--check constraints
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max)) + '],

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''table''

,@level1name = ''' + object_name(cc.parent_object_id) + '''

,@level2type = ''constraint''

,@level2name = ''' + cc.name + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''table''

,@level1name = ''' + object_name(cc.parent_object_id) + '''

,@level2type = ''constraint''

,@level2name = ''' + cc.name + ''''
from
    sys.extended_properties sep
    join sys.check_constraints cc
        on sep.major_id = cc.object_id
union

--check constraints
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max)) + '],

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''table''

,@level1name = ''' + object_name(cc.parent_object_id) + '''

,@level2type = ''constraint''

,@level2name = ''' + cc.name + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''table''

,@level1name = ''' + object_name(cc.parent_object_id) + '''

,@level2type = ''constraint''

,@level2name = ''' + cc.name + ''''
from
    sys.extended_properties sep
    join sys.default_constraints cc
        on sep.major_id = cc.object_id
union

--views
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max)) + '],

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''view''

,@level1name = ''' + object_name(sep.major_id) + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''view''

,@level1name = ''' + object_name(sep.major_id) + '''' + '

END

'
from
    sys.extended_properties sep
    join sys.views t
        on sep.major_id = t.object_id
where
    sep.class_desc = 'OBJECT_OR_COLUMN'
    and sep.minor_id = 0
union

--sprocs
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max)) + '],

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''procedure''

,@level1name = ''' + object_name(sep.major_id) + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''procedure''

,@level1name = ''' + object_name(sep.major_id) + '''' + '

END

' + '

END

'
from
    sys.extended_properties sep
    join sys.procedures t
        on sep.major_id = t.object_id
where
    sep.class_desc = 'OBJECT_OR_COLUMN'
    and sep.minor_id = 0
union

--FKs
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max)) + '],

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''table''

,@level1name = ''' + object_name(cc.parent_object_id) + '''

,@level2type = ''constraint''

,@level2name = ''' + cc.name + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty

@name = ''' + sep.name + '''

,@level0type = ''schema''

,@level0name = ''' + object_schema_name(sep.major_id) + '''

,@level1type = ''table''

,@level1name = ''' + object_name(cc.parent_object_id) + '''

,@level2type = ''constraint''

,@level2name = ''' + cc.name + ''''
from
    sys.extended_properties sep
    join sys.foreign_keys cc
        on sep.major_id = cc.object_id
union

--PKs
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max))
    + '],@level0type = N''SCHEMA'', @level0name = [' + SCH.name + '], @level1type = ''TABLE'', @level1name = ['
    + TBL.name + '] , @level2type = ''CONSTRAINT'', @level2name = [' + SKC.name + '] ,@name = '''
    + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty  @level0type = N''SCHEMA'', @level0name = [' + SCH.name
    + '], @level1type = ''TABLE'', @level1name = [' + TBL.name + '] , @level2type = ''CONSTRAINT'', @level2name = ['
    + SKC.name + '] ,@name = ''' + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + ''''
from
    sys.tables TBL
    inner join sys.schemas SCH
        on TBL.schema_id = SCH.schema_id
    inner join sys.extended_properties SEP
    inner join sys.key_constraints SKC
        on SEP.major_id = SKC.object_id
        on TBL.object_id = SKC.parent_object_id
where
    SKC.type_desc = N'PRIMARY_KEY_CONSTRAINT'
union

--Table triggers
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max))
    + '],@level0type = N''SCHEMA'', @level0name = [' + SCH.name + '], @level1type = ''TABLE'', @level1name = ['
    + TBL.name + '] , @level2type = ''TRIGGER'', @level2name = [' + TRG.name + '] ,@name = '''
    + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty  @level0type = N''SCHEMA'', @level0name = [' + SCH.name
    + '], @level1type = ''TABLE'', @level1name = [' + TBL.name + '] , @level2type = ''TRIGGER'', @level2name = ['
    + TRG.name + '] ,@name = ''' + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + ''''
from
    sys.tables TBL
    inner join sys.triggers TRG
        on TBL.object_id = TRG.parent_id
    inner join sys.extended_properties SEP
        on TRG.object_id = SEP.major_id
    inner join sys.schemas SCH
        on TBL.schema_id = SCH.schema_id
union

--UDF
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max))
    + '],@level0type = N''SCHEMA'', @level0name = [' + SCH.name + '], @level1type = ''FUNCTION'', @level1name = ['
    + OBJ.name + '] , @name = ''' + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty  @level0type = N''SCHEMA'', @level0name = [' + SCH.name
    + '], @level1type = ''FUNCTION'', @level1name = [' + OBJ.name + '] ,@name = '''
    + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

END

'
from
    sys.extended_properties SEP
    inner join sys.objects OBJ
        on SEP.major_id = OBJ.object_id
    inner join sys.schemas SCH
        on OBJ.schema_id = SCH.schema_id
where
    SEP.class_desc = N'OBJECT_OR_COLUMN'
    and OBJ.type in ('FN', 'IF', 'TF')
union

--UDF params
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max))
    + '],@level0type = N''SCHEMA'', @level0name = [' + SCH.name + '], @level1type = ''FUNCTION'', @level1name = ['
    + OBJ.name + '] , @level2type = ''PARAMETER'', @level2name = [' + PRM.name + '] ,@name = '''
    + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty  @level0type = N''SCHEMA'', @level0name = [' + SCH.name
    + '], @level1type = ''FUNCTION'', @level1name = [' + OBJ.name + '] , @level2type = ''PARAMETER'', @level2name = ['
    + PRM.name + '] ,@name = ''' + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

END

'
from
    sys.extended_properties SEP
    inner join sys.objects OBJ
        on SEP.major_id = OBJ.object_id
    inner join sys.schemas SCH
        on OBJ.schema_id = SCH.schema_id
    inner join sys.parameters PRM
        on SEP.major_id = PRM.object_id
           and SEP.minor_id = PRM.parameter_id
where
    SEP.class_desc = N'PARAMETER'
    and OBJ.type in ('FN', 'IF', 'TF')
union

--sp params
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max))
    + '], @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '],  @level1type = ''PROCEDURE'', @level1name = ['
    + SPR.name + '] , @level2type = ''PARAMETER'', @level2name = [' + PRM.name + '] ,@name = '''
    + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty  @level0type = N''SCHEMA'', @level0name = [' + SCH.name
    + '], @level1type = ''PROCEDURE'', @level1name = [' + SPR.name + '] , @level2type = ''PARAMETER'', @level2name = ['
    + PRM.name + '] ,@name = ''' + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

END

'
from
    sys.extended_properties SEP
    inner join sys.procedures SPR
        on SEP.major_id = SPR.object_id
    inner join sys.schemas SCH
        on SPR.schema_id = SCH.schema_id
    inner join sys.parameters PRM
        on SEP.major_id = PRM.object_id
           and SEP.minor_id = PRM.parameter_id
where
    SEP.class_desc = N'PARAMETER'
union

--DB
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max)) + '],@name = '''
    + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty  @name = ''' + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

END

'
from
    sys.extended_properties SEP
where
    class_desc = N'DATABASE'
union

--schema
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max))
    + '],@level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@name = '''
    + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty  @level0type = N''SCHEMA'', @level0name = [' + SCH.name + '] ,@name = '''
    + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

END

'
from
    sys.extended_properties SEP
    inner join sys.schemas SCH
        on SEP.major_id = SCH.schema_id
where
    SEP.class_desc = N'SCHEMA'
union

--DATABASE_FILE
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max))
    + '],@level0type = N''FILEGROUP'', @level0name = [' + DSP.name
    + '], @level1type = ''LOGICAL FILE NAME'', @level1name = ' + DBF.name + ' ,@name = '''
    + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty  @level0type = N''FILEGROUP'', @level0name = [' + DSP.name
    + '], @level1type = ''LOGICAL FILE NAME'', @level1name = ' + DBF.name + ' ,@name = '''
    + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

END

'
from
    sys.extended_properties SEP
    inner join sys.database_files DBF
        on SEP.major_id = DBF.file_id
    inner join sys.data_spaces DSP
        on DBF.data_space_id = DSP.data_space_id
where
    SEP.class_desc = N'DATABASE_FILE'
union

--filegroup
select
    Major_Id
,   Minor_ID
,   sep.Name
,   Value = sep.value
,   CreateScript = 'IF NOT EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  ) ' + '

Begin

EXEC sys.sp_addextendedproperty @value= [' + cast(Sep.value as nvarchar(max))
    + '],@level0type = N''FILEGROUP'', @level0name = [' + DSP.name + '] ,@name = '''
    + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

End '
,   DropScript = 'IF EXISTS

(SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] =  ' + cast(major_Id as nvarchar(max)) + '  AND [name] = '''
    + sep.Name + ''' AND [minor_id] =  ' + cast(minor_Id as nvarchar(max)) + '  )

Begin

EXEC sys.sp_dropextendedproperty  @level0type = N''FILEGROUP'', @level0name = [' + DSP.name + '] ,@name = '''
    + replace(cast(SEP.name as nvarchar(300)), '''', '''''') + '''' + '

END

'
from
    sys.extended_properties SEP
    inner join sys.data_spaces DSP
        on SEP.major_id = DSP.data_space_id
where
    DSP.type_desc = 'ROWS_FILEGROUP'