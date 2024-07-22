-- =============================================================================
-- Author:		Mikael Sikora
-- Create date: 2017-11-06
-- Description:	Stored procedure - list out all folder permissions for members.
--              CAC = ContentAccessControl
-- 				F   = Folder
-- 				FAS = FolderAccessSMALL (FolderAccess)
-- 				M   = Member
-- 				MC  = MemberCache
-- =============================================================================

USE [r2w_reportcenter1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Company].[sp_CheckContentAccessControlMemberPermissions] AS
BEGIN
	SET NOCOUNT ON;
	-- Identify new folder records, check against ContentAccessControl records,
	-- if match, update folderaccess table with new entries
	DECLARE @CACMemberVariable varchar (400)
		  , @CACPathVariable   varchar (400)
		  , @CACLoopCounter    INT
		  , @CACMaxID          INT
		  , @MIdVariable       INT
		  , @MNameVariable     varchar (400)
	
	-- Populate the counters
	SELECT @CACLoopCounter = min(cac.ID)
		 , @CACMaxID       = max(cac.ID)
	FROM r2w_reportcenter1.Company.ContentAccessControl cac (NOLOCK)
	PRINT 'CACMaxID = ' + CAST(@CACMaxID AS VARCHAR)

	-- Check ContentAccessControl Table
	Select * from r2w_reportcenter1.Company.ContentAccessControl (NOLOCK)

	-- [Iterate through the ContentAccessControl table]
	WHILE (@CACLoopCounter IS NOT NULL
		AND @CACLoopCounter <= @CACMaxID)
	BEGIN
		-- Set veriables to NULL for error handling
		SET @CACMemberVariable = NULL
		SET @MIdVariable       = NULL
		SET @MNameVariable     = NULL

		-- [Identify the wildcard expressions]
		PRINT 'CAC Loop ' + CAST(@CACLoopCounter AS VARCHAR)
		SELECT @CACMemberVariable = cac.MemberExpression
		FROM r2w_reportcenter1.Company.ContentAccessControl cac (NOLOCK)
		WHERE cac.ID = @CACLoopCounter
		PRINT 'MemberExpression = ' + @CACMemberVariable
		IF ( (@CACMemberVariable IS NULL)
			   OR (@CACMemberVariable = '')
			   OR (@CACMemberVariable = '%') )
			PRINT '*** NOT VALID - CAC.FolderMemberExpression: [' + @CACMemberVariable + ']'; 
		ELSE 
		BEGIN
			-- [Verify Member expression exists in Members table and
			--  insert into Member ID and Name variables]
			SELECT @MIdVariable = m.id
				, @MNameVariable = m.name
			FROM r2w_reportcenter1.dbo.member m (NOLOCK)
			WHERE EXISTS
				(SELECT m.name
				 FROM r2w_reportcenter1.dbo.member m2 (NOLOCK)
				 WHERE m.name = @CACMemberVariable
				)
			PRINT 'MemberNameVariable = ' + @MNameVariable 
			  + '; MemberIDVariable = '   +  CAST(@MIdVariable AS VARCHAR)

			-- If @MIdVariable remains NULL, then bypass this member iteration
			IF (@MIdVariable IS NULL)
				PRINT '*** NOT FOUND - CAC.MemberExpression in dbo.member.name: [' + @CACMemberVariable + ']';
			ELSE
			BEGIN
				-- Display folder assignments for group member 
				SELECT DISTINCT
					m.id                     as 'Member.Id'
				  , m.name                   as 'Member.Name'
				  , f.id                     as 'Folder.Id'
				  , f.parentid               as 'Folder.ParentId'
				  , f.name                   as 'Folder.Name'
				  , f.[path]                 as 'Folder.Path'
				  , fas.folderpermission     as 'FolderAccess.FolderPermission'
				  , fas.delegationpermission as 'FolderAccess.DelegationPermission'
				  , fas.syncpermission       as 'FolderAccess.SyncPermission'
				  , fas.propagative          as 'FolderAccess.Propagative'
				FROM r2w_reportcenter1.Company.folderaccessSMALL fas (NOLOCK)
				JOIN r2w_reportcenter1.dbo.member m (NOLOCK)
				  ON m.id = fas.memberid
				JOIN r2w_reportcenter1.dbo.folder f (NOLOCK)
				  ON f.id = fas.folderid
				WHERE EXISTS
					(SELECT 1
					FROM r2w_reportcenter1.dbo.membercache mc (NOLOCK)
					WHERE fas.memberid = mc.memberid)
					AND m.name = @MNameVariable
			PRINT '--- SUCCESSFUL VERIFICATION: [' + @MNameVariable + ']'
			END
		END
		SET @CACLoopCounter = @CACLoopCounter + 1
	END

END
GO
