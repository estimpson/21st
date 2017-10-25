CREATE TABLE [dbo].[ole_objects]
(
[id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ole_object] [image] NULL,
[parent_id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[date_stamp] [datetime] NULL,
[serial] [int] NOT NULL,
[parent_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_ole_objects_i] on [dbo].[ole_objects] for insert
as
begin
	-- declare local variables
	declare @serial integer
	
	-- if trying to update more than 1 row exit
	if @@rowcount > 1
		raiserror 99999 'Multi-row insert on table ole_objects not allowed!'
		
	-- get inserted serial
	select	@serial = serial 
	from 	inserted
	
	if @serial = 0
	begin
		update 	ole_objects
		set	serial = isnull ( (	select	max(serial)
						from	ole_objects ), 0 ) + 1
		where	serial = 0
	end
end
GO
ALTER TABLE [dbo].[ole_objects] ADD CONSTRAINT [PK__ole_objects__1FE396DB] PRIMARY KEY CLUSTERED  ([serial]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ole_objects_ui1] ON [dbo].[ole_objects] ([parent_id], [id]) ON [PRIMARY]
GO
