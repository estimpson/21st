CREATE TABLE [dbo].[entitlement_proration_basis]
(
[entitlement] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[basis_operator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[entitlement_proration_basis] ADD CONSTRAINT [pk_entitlement_proration_basis] PRIMARY KEY CLUSTERED  ([entitlement], [pay_type]) ON [PRIMARY]
GO
