CREATE TABLE [dbo].[employee]
(
[name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[operator_code] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[password] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[serial_number] [int] NULL,
[epassword] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[operatorlevel] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_employee_d] on  [dbo].[employee] 
for delete
as
begin
	declare @operator_code varchar (8),
		@password      varchar (8)

	select	@operator_code = operator_code,
		@password      = password
	from	deleted

	if @@rowcount = 1 
		delete from requisition_security 
		where  operator_code = @operator_code
		and    password = @password 
	
end
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_employee_i] on  [dbo].[employee] 
for insert
as
begin
	declare @operator_code varchar (8),
		@password      varchar (8)

	if exists ( select 1 from parameters where requisition = 'Y' )
	begin
		select	@operator_code = operator_code,
			@password      = password
		from	inserted
	
		if @@rowcount = 1 
			insert into requisition_security (
			operator_code,
			password,
			security_level,
			dollar,
			approver,
			approver_password,
			backup_approver,
			backup_approver_password,
			backup_approver_end_date,
			dollar_week_limit,
	        	account_group_code,
			project_group_code,
			self_dollar_limit,
			name )
			select 	operator_code, 
				password,
				null,
				0,
				null,
				null,
				null,
				null,
				null,
				0,
				null,
				null,
				0,
				name
			from inserted
	end
end
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_employee_u] on  [dbo].[employee] 
for update
as
begin
	declare @operator_old varchar (8),
		@password_old varchar (8),
		@operator_new varchar (8),
		@password_new varchar (8)

	select	@operator_old = operator_code,
		@password_old = password
	from	deleted

	select	@operator_new = operator_code,
		@password_new = password
	from	inserted

	if @operator_old <> @operator_new
		update requisition_security
		set    operator_code = @operator_new
		where  operator_code = @operator_old 
		and    password = @password_old
        else if @password_old <> @operator_new
		update requisition_security
		set    password = @password_new
		where  operator_code = @operator_old 
		and    password = @password_old

end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[tr_employee_i] on [dbo].[employee] for insert
as
insert
	FT.Users
(	OperatorCode
)
select
	operator_code
from
	inserted
GO
ALTER TABLE [dbo].[employee] ADD CONSTRAINT [PK__employee__10A1534B] PRIMARY KEY CLUSTERED  ([operator_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee] ADD CONSTRAINT [UQ__employee__11957784] UNIQUE NONCLUSTERED  ([password]) ON [PRIMARY]
GO
