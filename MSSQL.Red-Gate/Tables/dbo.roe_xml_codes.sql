CREATE TABLE [dbo].[roe_xml_codes]
(
[roe_xml_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[roe_xml_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[roe_xml_description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[roe_xml_codes] ADD CONSTRAINT [pk_roe_xml_codes] PRIMARY KEY NONCLUSTERED  ([roe_xml_type], [roe_xml_code]) ON [PRIMARY]
GO
