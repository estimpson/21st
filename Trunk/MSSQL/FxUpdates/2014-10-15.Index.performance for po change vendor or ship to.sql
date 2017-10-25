
create index ix_ReceiverHeaders_Status on dbo.ReceiverHeaders (Status) include (ReceiverID)

create index ix_AuditTrail_PO on dbo.audit_trail (type, po_number)