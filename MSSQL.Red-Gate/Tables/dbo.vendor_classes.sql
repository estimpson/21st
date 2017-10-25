CREATE TABLE [dbo].[vendor_classes]
(
[vendor_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[vendor_class_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hide_addresses] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[vendor_classes] ADD CONSTRAINT [pk_vendor_classes] PRIMARY KEY CLUSTERED  ([vendor_class]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
