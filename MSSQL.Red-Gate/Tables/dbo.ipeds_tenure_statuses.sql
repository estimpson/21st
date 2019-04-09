CREATE TABLE [dbo].[ipeds_tenure_statuses]
(
[ipeds_tenure_status] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ipeds_tenure_status_description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sort_order] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ipeds_tenure_statuses] ADD CONSTRAINT [pk_ipeds_tenure_statuses] PRIMARY KEY CLUSTERED  ([ipeds_tenure_status]) ON [PRIMARY]
GO
