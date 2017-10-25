CREATE TABLE [dbo].[FT_Temp_TelescopicParts]
(
[TelescopicPart] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OldTelescopicPart] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FT_Temp_TelescopicParts] ADD CONSTRAINT [PK_FT_Temp_TelescopicParts] PRIMARY KEY CLUSTERED  ([TelescopicPart]) ON [PRIMARY]
GO
