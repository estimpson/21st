CREATE TABLE [dbo].[company_state_filings]
(
[company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[state_id] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[taxpayer_id_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sui_percent] [decimal] (12, 6) NULL,
[contact_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_phone] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_extension] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employer_id_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seasonal_indicator] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[remitter_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reimbursable_employer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_email] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_state_filings] ADD CONSTRAINT [pk_company_state_filings] PRIMARY KEY CLUSTERED  ([company], [state_id]) ON [PRIMARY]
GO
