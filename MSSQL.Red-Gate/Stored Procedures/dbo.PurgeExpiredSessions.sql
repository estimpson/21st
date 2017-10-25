SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PurgeExpiredSessions] @ad_expired_date datetime
AS

 BEGIN
	SET NOCOUNT ON
	delete from user_sessions where expiration_date <= @ad_expired_date
 END
GO
