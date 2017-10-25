CREATE TABLE [dbo].[equipment_codes]
(
[equipment_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[equipment_code_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[equipment_codes] ADD CONSTRAINT [pk_equipment_codes] PRIMARY KEY CLUSTERED  ([equipment_code]) ON [PRIMARY]
GO
