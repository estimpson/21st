SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE AGGREGATE [Fx].[ToList] (@value [nvarchar] (max))
RETURNS [nvarchar] (max)
EXTERNAL NAME [FxAggregates].[ToList]
GO
