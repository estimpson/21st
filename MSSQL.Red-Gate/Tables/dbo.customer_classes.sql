CREATE TABLE [dbo].[customer_classes]
(
[customer_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customer_class_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[customer_classes] ADD CONSTRAINT [pk_customer_classes] PRIMARY KEY CLUSTERED  ([customer_class]) ON [PRIMARY]
GO
