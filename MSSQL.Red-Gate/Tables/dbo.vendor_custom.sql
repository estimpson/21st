CREATE TABLE [dbo].[vendor_custom]
(
[code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[custom1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom3] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom4] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom5] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[vendor_custom] ADD CONSTRAINT [PK__vendor_custom__3F5C4234] PRIMARY KEY CLUSTERED  ([code]) ON [PRIMARY]
GO
