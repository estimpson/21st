CREATE TABLE [dbo].[computed_values]
(
[row_number] [smallint] NOT NULL,
[decimal_18_6] [decimal] (18, 6) NOT NULL,
[decimal_18_5] [decimal] (18, 5) NOT NULL,
[decimal_18_4] [decimal] (18, 4) NOT NULL,
[decimal_18_3] [decimal] (18, 3) NOT NULL,
[decimal_18_2] [decimal] (18, 2) NOT NULL,
[decimal_18_1] [decimal] (18, 1) NOT NULL,
[null_date] [datetime] NULL,
[text_column] [varchar] (3800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[computed_values] ADD CONSTRAINT [pk_computed_values] PRIMARY KEY CLUSTERED  ([row_number]) ON [PRIMARY]
GO
