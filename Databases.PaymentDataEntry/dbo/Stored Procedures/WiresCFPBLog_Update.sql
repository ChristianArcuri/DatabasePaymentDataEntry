CREATE PROCEDURE [dbo].[WiresCFPBLog_Update]
	@CFPBLogId int, 
	@AgSenderSeq int
AS
BEGIN 
	UPDATE WiresCFPBLog 
		SET AgSenderSeq = @AgSenderSeq
	WHERE CFPBLogId = @CFPBLogId			      
END