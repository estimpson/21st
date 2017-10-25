CREATE TABLE [FT].[New22_Seats_part_machine]
(
[part] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[machine] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sequence] [int] NULL,
[mfg_lot_size] [numeric] (20, 6) NULL,
[process_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parts_per_cycle] [numeric] (20, 6) NULL,
[parts_per_hour] [numeric] (20, 6) NULL,
[cycle_unit] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cycle_time] [numeric] (20, 6) NULL,
[overlap_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[overlap_time] [numeric] (6, 2) NULL,
[labor_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[activity] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[setup_time] [numeric] (20, 6) NULL,
[crew_size] [decimal] (20, 6) NULL
) ON [PRIMARY]
GO
