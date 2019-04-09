CREATE TABLE [dbo].[fa_asset_history]
(
[asset_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asset_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asset_event_date] [datetime] NOT NULL,
[sequence_number] [decimal] (4, 0) NOT NULL,
[column_changed] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[old_value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[event_reason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fiscal_period] [decimal] (4, 0) NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acquisition_asset] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[depreciation_accumulated] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[depreciation_book] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[depreciation_calc_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glentry_fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glentry_fiscal_period] [int] NULL,
[gl_date] [datetime] NULL,
[import_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_asset_history] ADD CONSTRAINT [pk_fa_asset_history] PRIMARY KEY CLUSTERED  ([asset_id], [asset_event], [asset_event_date], [sequence_number], [column_changed]) ON [PRIMARY]
GO
