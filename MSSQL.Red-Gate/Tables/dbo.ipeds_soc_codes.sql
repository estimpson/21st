CREATE TABLE [dbo].[ipeds_soc_codes]
(
[soc_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[soc_code_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[soc_code_sort] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ipeds_soc_codes] ADD CONSTRAINT [pk_ipeds_soc_codes] PRIMARY KEY CLUSTERED  ([soc_code]) ON [PRIMARY]
GO
