SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_post_acct_je_by_period]
AS
SELECT
	journal_entries.fiscal_year,
	journal_entries.ledger,
	journal_entries.gl_entry,
	journal_entries.entry_date,
	journal_entries.period,
	journal_entries.entry_type,
	journal_entries.document_source,
	journal_entry_lines.amount,
	journal_entries.je_description,
	journal_entries.changed_user_id,
	journal_entry_lines.ledger_account,
	journal_entry_lines.balance_name
FROM
	journal_entries INNER JOIN
	journal_entry_lines ON
		journal_entries.fiscal_year = journal_entry_lines.fiscal_year AND
		journal_entries.gl_entry = journal_entry_lines.gl_entry AND
		journal_entries.ledger = journal_entry_lines.ledger
GO
