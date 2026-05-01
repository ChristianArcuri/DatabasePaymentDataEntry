
CREATE procedure [dbo].[SentEmailForWireStoped]
as
  set nocount on;
  
  declare @WireId int, @Result varchar(max), @MsgId int, @return_value int

  declare curPF cursor for
	select T1.WireId
	from WirePossibleFraud T1
	  join Wires T2 ON T1.WireId = T2.WireId
	where EmailSent is null and Created > '3/6/2014' and AgSenderCode not in ('FL1000')

 Open curPF
 while 1=1
 begin
   FETCH NEXT FROM curPF INTO @WireId 
   if @@FETCH_STATUS <> 0
     Break

   exec GetPossibleFraudeRreason @WireId, @Result output
   
	EXEC	WireSearch.dbo.[SendEmail]  
			@SenderEmail = N'italert@example.com',
			@SenderName = N'System Alert',
			@Email = 'aibarra@example.com',
			@Subject = 'Wire Stoped',
			@MsgBody = @Result,
			@Tag = N'1',
			@MsgId = @MsgId OUTPUT

	EXEC	WireSearch.dbo.[SendEmail]  
			@SenderEmail = N'italert@example.com',
			@SenderName = N'System Alert',
			@Email = 'gschnaider@example.com',--N'aibarra@example.com',
			@Subject = 'Wire Stoped',
			@MsgBody = @Result,
			@Tag = N'1',
			@MsgId = @MsgId OUTPUT

	EXEC	WireSearch.dbo.[SendEmail]  
			@SenderEmail = N'italert@example.com',
			@SenderName = N'System Alert',
			@Email = 'wvelez@example.com',--N'aibarra@example.com',
			@Subject = 'Wire Stoped',
			@MsgBody = @Result,
			@Tag = N'1',
			@MsgId = @MsgId OUTPUT

   update WirePossibleFraud set EmailSent = GETDATE()
   where WireId = @WireId
      
 end
 
 Close curPF
 Deallocate curPF
 
 