SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[FormulateSQL](@as_dbcolname varchar(500),
                             @as_coltype   varchar(25),
                             @as_criteria  varchar(4000),
                             @as_userid    varchar(25) )
RETURNS varchar(8000)
AS
BEGIN
  DECLARE @s_rangeseparator      varchar(25),
          @s_listseparator       varchar(25),
          @s_wildcardcharacter   varchar(25),
          @s_dbcolname           varchar(500),
          @s_coltype             varchar(25),
          @s_criteria            varchar(4000),
          @s_joinoperator        varchar(5),
          @s_begvalue            varchar(50),
          @s_parsedvalue         varchar(50),
          @s_inlist              varchar(4000),
          @s_inlistseparator     varchar(5),
          @s_listoperator        varchar(4),
          @s_listbegin           varchar(1),
          @s_listend             varchar(1),
          @s_comma               varchar(1),
          @s_sqlstatement        varchar(8000),
          @i_hyphenpos           integer,
          @i_commapos            integer,
          @i_inlistpos           integer,
          @s_lastparsehyphen     char(1)

  SELECT @s_rangeseparator = IsNull(value,'')
    FROM preferences_user
   WHERE preference = 'ReportSelectionRangeSeparator'
     AND security_id = @as_userid
  IF @@rowcount = 0
  BEGIN
    SELECT @s_rangeseparator = IsNull(value,'')
      FROM preferences_standard
     WHERE preference = 'ReportSelectionRangeSeparator'
    IF @@rowcount = 0 OR @s_rangeseparator = '' SELECT @s_rangeseparator = '-'
  END

  SELECT @s_listseparator = IsNull(value,'')
    FROM preferences_user
   WHERE preference = 'ReportSelectionListSeparator'
     AND security_id = @as_userid
  IF @@rowcount = 0
  BEGIN
    SELECT @s_listseparator = IsNull(value,'')
      FROM preferences_standard
     WHERE preference = 'ReportSelectionListSeparator'
    IF @@rowcount = 0 OR @s_listseparator = '' SELECT @s_listseparator = ','
  END

  SELECT @s_wildcardcharacter = IsNull(value,'')
    FROM preferences_user
   WHERE preference = 'ReportSelectionWildcardCharacter'
     AND security_id = @as_userid
  IF @@rowcount = 0
  BEGIN
    SELECT @s_wildcardcharacter = IsNull(value,'')
      FROM preferences_standard
     WHERE preference = 'ReportSelectionWildcardCharacter'
    IF @@rowcount = 0 OR @s_wildcardcharacter = '' SELECT @s_wildcardcharacter = '%'
  END

  SELECT @s_criteria = @as_criteria,
         @s_coltype = Lower(@as_coltype),
         @s_inlist = '',
         @s_inlistseparator = '^%^',
         @s_comma = '',
         @s_sqlstatement = '',
         @s_lastparsehyphen = 'N'

  IF @s_coltype = 'date'
    SELECT @s_dbcolname = 'Convert(char(10),' + @as_dbcolname + ',111)'
  ELSE
    SELECT @s_dbcolname = @as_dbcolname

  SELECT @i_hyphenpos = CHARINDEX(@s_rangeseparator,@s_criteria),
         @i_commapos = CHARINDEX(@s_listseparator,@s_criteria)

  -- Set list separator position to end of string if not found
  IF @i_commapos = 0 SELECT @i_commapos = Len(@s_criteria)

  WHILE @i_hyphenpos <> 0 OR @i_commapos <> 0
  BEGIN
    SELECT @s_joinoperator = ''
    IF @s_sqlstatement <> '' SELECT @s_joinoperator = ' OR '

    IF @i_commapos < @i_hyphenpos OR @i_hyphenpos = 0
    BEGIN
      -- Comma processing. Get the value before the comma
      IF @i_commapos = Len(@s_criteria)
        SELECT @s_parsedvalue = @s_criteria,
               @s_criteria = ''
      ELSE
        SELECT @s_parsedvalue = LTrim(RTrim(Left(@s_criteria, @i_commapos - 1))),
               @s_criteria = Substring(@s_criteria,@i_commapos + 1, Len(@s_criteria) - @i_commapos)

      IF @s_lastparsehyphen = 'Y'
      BEGIN
        -- have the beginning value so this parsed value must be the ending value... construct between statement
        IF @s_coltype = 'date'
        BEGIN
          IF IsDate(@s_begvalue) = 1 AND IsDate(@s_parsedvalue) = 1
            SELECT @s_sqlstatement = @s_sqlstatement + @s_joinoperator + '(' + @s_dbcolname +
                 ' BETWEEN ''' + Convert(char(10),convert(datetime,@s_begvalue),111) +
                 ''' AND ''' + Convert(char(10),convert(datetime,@s_parsedvalue),111) + ''')'
        END
        ELSE IF @s_coltype = 'number'
        BEGIN
          IF IsNumeric(@s_begvalue) = 1 AND IsNumeric(@s_parsedvalue) = 1
                SELECT @s_sqlstatement = @s_sqlstatement + @s_joinoperator + '(' + @s_dbcolname +
                     ' BETWEEN ' + @s_begvalue + ' AND ' + @s_parsedvalue + ')'
        END
        ELSE
        BEGIN
          --assume string
          SELECT @s_sqlstatement = @s_sqlstatement + @s_joinoperator + '(' + @s_dbcolname +
               ' BETWEEN ''' + @s_begvalue + ''' AND ''' + @s_parsedvalue + ''')'
        END
        SELECT @s_lastparsehyphen = 'N'
      END
      ELSE -- last parse didn't end in a hyphen
      BEGIN
        IF Lower(@s_coltype) <> 'date' AND Lower(@s_coltype) <> 'number'
        AND CHARINDEX(@s_wildcardcharacter,@s_parsedvalue) > 0
          -- LIKE processing for a string
          SELECT @s_sqlstatement = @s_sqlstatement + @s_joinoperator + '(' + @s_dbcolname +
                    ' LIKE ''' + @s_parsedvalue + ''')'
        ELSE
        BEGIN
          --store this value for the in statement that we will formulate later
          IF @s_inlist = ''
            SELECT @s_inlist = @s_parsedvalue,
                   @s_listoperator = '=',
                   @s_listbegin = '',
                   @s_listend = ''
          ELSE
            SELECT @s_inlist = @s_inlist + @s_inlistseparator + @s_parsedvalue,
                   @s_listoperator = ' IN ',
                   @s_listbegin = '(',
                   @s_listend = ')'
        END
      END
    END
	ELSE
    BEGIN
      -- Hyphen processing. Save the beginning value
      SELECT @s_begvalue = LTrim(RTrim(Left(@s_criteria, @i_hyphenpos - 1)))
      -- strip off the value and separator character(s)
      SELECT @s_criteria = Substring(@s_criteria,@i_hyphenpos + 1, Len(@s_criteria) - @i_hyphenpos)
      -- Set this flag so that we'll know to wait for the ending value before
      -- generating the SQL statement
      SELECT @s_lastparsehyphen = 'Y'
    END

	-- Are there any more hyphens or commas?
    SELECT @i_hyphenpos = CHARINDEX(@s_rangeseparator,@s_criteria),
           @i_commapos = CHARINDEX(@s_listseparator,@s_criteria)
    IF @i_commapos = 0 SELECT @i_commapos = Len(@s_criteria)
  END

  -- Create an IN/= statement if we have stored anything in the in list
  IF @s_inlist <> ''
  BEGIN
    SELECT @s_joinoperator = ''
    IF @s_sqlstatement <> '' SELECT @s_joinoperator = ' OR '
    SELECT @s_sqlstatement = @s_sqlstatement + @s_joinoperator + '(' + @s_dbcolname +
           + @s_listoperator + @s_listbegin

    WHILE @s_inlist <> ''
    BEGIN
      SELECT @i_inlistpos = CHARINDEX(@s_inlistseparator,@s_inlist)
      IF @i_inlistpos = 0
      BEGIN
        SELECT @s_parsedvalue = @s_inlist
        SELECT @s_inlist = ''
      END
      ELSE
      BEGIN
        SELECT @s_parsedvalue = LTrim(RTrim(Left(@s_inlist, @i_inlistpos - 1)))
        -- strip off the value and separator character(s)
        SELECT @s_inlist = Substring(@s_inlist,@i_inlistpos + Len(@s_inlistseparator),
                     Len(@s_inlist) - @i_inlistpos + Len(@s_inlistseparator) - 1)
      END
      -- have the next value.  Add it to the list
      IF @s_coltype = 'date'
      BEGIN
        IF IsDate(@s_parsedvalue) = 1
            SELECT @s_sqlstatement = @s_sqlstatement + @s_comma +
                 '''' + Convert(char(10),convert(datetime,@s_parsedvalue),111) + ''''
      END
      ELSE IF @s_coltype = 'number'
      BEGIN
        IF IsNumeric(@s_parsedvalue) = 1
            SELECT @s_sqlstatement = @s_sqlstatement + @s_comma + @s_parsedvalue
      END
      ELSE
      BEGIN
        --assume string
        SELECT @s_sqlstatement = @s_sqlstatement + @s_comma + '''' + @s_parsedvalue + ''''
      END
      SELECT @s_comma = ','
    END

    SELECT @s_sqlstatement = @s_sqlstatement + @s_listend + ')'
  END

  IF @s_sqlstatement <> '' SELECT @s_sqlstatement = '(' + @s_sqlstatement + ')'

  RETURN @s_sqlstatement
END
GO
