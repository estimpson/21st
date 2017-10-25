CREATE TABLE [dbo].[ipeds_academic_ranks]
(
[academic_rank] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[academic_rank_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[academic_rank_sort] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ipeds_academic_ranks] ADD CONSTRAINT [pk_ipeds_academic_ranks] PRIMARY KEY CLUSTERED  ([academic_rank]) ON [PRIMARY]
GO
