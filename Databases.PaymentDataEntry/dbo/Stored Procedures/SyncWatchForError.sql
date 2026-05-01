create procedure SyncWatchForError
as 
  set nocount on;

  declare @D datetime, @ErrMsg varchar(max)

  select @D = DATEADD(minute, -2, GETDATE()), @ErrMsg = null

  select @ErrMsg = 'Process: ' + Process + ' / Error: ' + ErrMsg
  from SyncErrorLog
  where Created >= @D

  select @ErrMsg
  
 if @ErrMsg is not null
  begin
	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'System notification',
		@recipients = 'aibarra@example.com;aeibarra.net@gmail.com',
		@body = @ErrMsg,
		@subject = 'Searching Sync from DE to Searching failed';
  end
  