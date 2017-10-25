CREATE TABLE [dbo].[fa_classes_account_preferences]
(
[fa_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acquisition_asset] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acquisition_liability] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[depreciation_accumulated] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[depreciation_expense] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[disposition_proceeds] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[disposition_gain_loss] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_classes_account_preferences] ADD CONSTRAINT [pk_fa_classes_account_preferences] PRIMARY KEY CLUSTERED  ([fa_class]) ON [PRIMARY]
GO
