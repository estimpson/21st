CREATE TABLE [dbo].[shop_floor_calendar]
(
[ai_id] [int] NOT NULL IDENTITY(1, 1),
[machine] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[begin_datetime] [datetime] NOT NULL,
[end_datetime] [datetime] NULL,
[labor_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crew_size] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[shop_floor_calendar] ADD CONSTRAINT [PK__shop_floor_calen__34DEB3C1] PRIMARY KEY CLUSTERED  ([ai_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[shop_floor_calendar] ADD CONSTRAINT [UQ__shop_floor_calen__35D2D7FA] UNIQUE NONCLUSTERED  ([machine], [begin_datetime]) ON [PRIMARY]
GO
