CREATE TABLE [dbo].[applicant_certificates]
(
[applicant] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[certificate] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[certificate_date] [datetime] NOT NULL,
[expire_date] [datetime] NULL,
[rating] [decimal] (18, 6) NULL,
[certificate_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cert_identity] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicant_certificates] ADD CONSTRAINT [pk_applicant_certificates] PRIMARY KEY CLUSTERED  ([applicant], [certificate], [certificate_date], [cert_identity]) ON [PRIMARY]
GO
