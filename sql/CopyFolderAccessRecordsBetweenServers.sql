-- ==============================================================
-- Author:		Mikael Sikora
-- Create date: 2017-11-13
-- Description:	Copies all folderaccess (fa1) table values from 
--				remote server to current server.  Link source DB.
-- ==============================================================

USE [master];
GO

DECLARE	@ServerName	 varchar(100);
SET		@ServerName  = 'xxnnxxxnn.xxxxxxnxxxn.us-west-2.rds.amazonaws.com';
IF NOT EXISTS (
	SELECT name 
	FROM [master].[sys].[servers]
	WHERE name = @ServerName
	)
EXEC	[sys].[sp_addlinkedserver] 
		@server		= @ServerName
	  , @srvproduct = 'SQL Server';
GO
-- VERIFY:  Check the new server link.
SELECT TOP 1000 *
  FROM [master].[sys].[servers];
GO

USE r2w_reportcenter1;
GO

-- DECLARE	@ServerName	 varchar(100);
DECLARE @CommitSize  int;
DECLARE @MaxID		 int;
DECLARE @LoopCounter int;

-- SET		@ServerName  = 'xxnnxxxnn.xxxxxxnxxxn.us-west-2.rds.amazonaws.com';
SET		@CommitSize  = 10000;

-- Copy data from source server to target server.
USE [r2w_reportcenter1];
IF OBJECT_ID('r2w_reportcenter1.dbo.folderaccess', 'U') IS NOT NULL
-- BEGIN
	SELECT @LoopCounter = min(folderaccess.ID)
		 , @MaxID		= max(folderaccess.ID)
	FROM [xxnnxxxnn.xxxxxxnxxxn.us-west-2.rds.amazonaws.com].r2w_reportcenter1.dbo.folderaccess
	-- FROM [@ServerName].r2w_reportcenter1.dbo.folderaccess;

	PRINT 'BEFORE LOOP:  CommitSize = '		+ CAST(@CommitSize AS VARCHAR)
					  + '; LoopCounter = '	+ CAST(@LoopCounter AS VARCHAR)
					  + '; MaxID = '		+ CAST(@MaxID AS VARCHAR);

	WHILE (@LoopCounter	IS NOT NULL
	   AND @LoopCounter	<= @MaxID)
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO r2w_reportcenter1.dbo.folderaccess (
					  folderid
					, memberid
					, folderpermission
					, delegationpermission
					, syncpermission
					, propagative
			)
			SELECT top (@CommitSize)
				  folderid				= fa1.folderid
				, memberid				= fa1.memberid
				, folderpermission		= fa1.folderpermission
				, delegationpermission	= fa1.delegationpermission
				, syncpermission		= fa1.syncpermission
				, propagative			= fa1.propagative
			FROM [xxnnxxxnn.xxxxxxnxxxn.us-west-2.rds.amazonaws.com].r2w_reportcenter1.dbo.folderaccess fa1
			-- FROM [@ServerName].r2w_reportcenter1.dbo.folderaccess fa1
			WHERE NOT EXISTS (
				SELECT 1
				FROM r2w_reportcenter1.dbo.folderaccess fa2 (NOLOCK)
				WHERE   fa2.folderid = fa1.folderid
					AND	fa2.memberid = fa1.memberid	
			);
		SET @LoopCounter = @LoopCounter + @CommitSize
		COMMIT TRANSACTION;
	PRINT 'COMMIT TRANSACTION.  LookCounter: ' + CAST(@LoopCounter AS VARCHAR)
	END;
-- END;
GO
-- VERIFY:  Check first 1000 records of target DB.
SELECT TOP 1000 *
FROM r2w_reportcenter1.dbo.folderaccess;
GO