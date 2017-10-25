CREATE TABLE [dbo].[so_order_processors]
(
[order_processor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[order_processor_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[so_order_processors] ADD CONSTRAINT [pk_so_order_processors] PRIMARY KEY CLUSTERED  ([order_processor]) ON [PRIMARY]
GO
