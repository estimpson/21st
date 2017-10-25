drop aggregate Fx.ToList
go

drop assembly [FxAggregates]
go

create assembly [FxAggregates]
authorization [dbo]
from 'c:\Temp\CLR\FxAggregates.dll'
go

alter assembly [FxAggregates]
drop file all
add file from 'c:\Temp\CLR\FxAggregates.dll'
go

print N'Creating [Fx].[ToList]...'
go

create aggregate [Fx].[ToList](@value nvarchar (max))
returns nvarchar (max)
external name [FxAggregates].[ToList]
go

