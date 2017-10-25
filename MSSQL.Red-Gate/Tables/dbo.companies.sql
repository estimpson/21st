CREATE TABLE [dbo].[companies]
(
[company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[company_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[taxpayer_id_number] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transmitter_control_code] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_1099] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone_1099_contact] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[net_futa_rate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employment_ins_contr_rate] [decimal] (18, 6) NULL,
[business_number] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[w2_contact] [varchar] (27) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[w2_contact_phone] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[w2_contact_extension] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[w2_contact_email] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[w2_contact_fax] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[w2_contact_notification] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[w2_pin] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_1099_contact] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trade_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_id_1099] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_id_w2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[kind_of_employer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[companies] ADD CONSTRAINT [pk_companies] PRIMARY KEY CLUSTERED  ([company]) ON [PRIMARY]
GO
