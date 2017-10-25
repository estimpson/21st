CREATE TABLE [dbo].[ar_customer_programs]
(
[customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[program] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[enroll_date] [datetime] NULL,
[cancel_date] [datetime] NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_to_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inventory_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[include_freight] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[program_identity] [int] NOT NULL IDENTITY(1, 1),
[pos_security_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ar_customer_programs] ADD CONSTRAINT [pk_ar_customer_programs] PRIMARY KEY CLUSTERED  ([customer], [program], [program_identity]) ON [PRIMARY]
GO
