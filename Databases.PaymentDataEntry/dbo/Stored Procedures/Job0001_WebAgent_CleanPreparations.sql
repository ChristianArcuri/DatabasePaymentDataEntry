CREATE PROCEDURE [dbo].[Job0001_WebAgent_CleanPreparations]
AS
BEGIN
  DECLARE @PreparationId uniqueidentifier
  DECLARE @D datetime

  SET @D = dbo.DateOnly(getdate())

  DECLARE cCursorClean cursor for
	select PreparationId 
	  from WebAgent_CleanPreparations
	Union 
	Select PreparationId 
	  FROM WebAgent_WireInPreparation
	 Where Created < @D
 

	OPEN cCursorClean
	FETCH cCursorClean INTO @PreparationId
	WHILE (@@Fetch_Status = 0)
		BEGIN
		  
			DELETE FROM WebAgent_WireInPreparation_Branches
			      WHERE PreparationId = @PreparationId

			DELETE FROM WebAgent_WireInPreparation_FXDetail
			      WHERE PreparationId = @PreparationId

			DELETE FROM WebAgent_WireInPreparation
			      WHERE PreparationId = @PreparationId

			DELETE FROM WebAgent_CleanPreparations
			      WHERE PreparationId = @PreparationId

		  FETCH cCursorClean INTO @PreparationId
	   END
	CLOSE cCursorClean
	DEALLOCATE cCursorClean

END
