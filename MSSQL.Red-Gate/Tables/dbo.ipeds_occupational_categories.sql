CREATE TABLE [dbo].[ipeds_occupational_categories]
(
[ipeds_occupational_category] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ipeds_occupational_category_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_occupational_category1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_occupational_category2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_occupational_category3] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_occupational_category4] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_occupational_category5] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_instructional_staff] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_instructional_staff_function] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sort_order] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ipeds_occupational_categories] ADD CONSTRAINT [pk_ipeds_occupational_categories] PRIMARY KEY CLUSTERED  ([ipeds_occupational_category]) ON [PRIMARY]
GO
