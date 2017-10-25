CREATE TABLE [dbo].[PartPutAwayLocations]
(
[PartCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LocationCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartPutAwayLocations] ADD CONSTRAINT [PK__PartPutAwayLocat__4A39C35A] PRIMARY KEY CLUSTERED  ([PartCode], [LocationCode]) ON [PRIMARY]
GO
