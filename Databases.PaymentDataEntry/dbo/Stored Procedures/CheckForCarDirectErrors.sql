Create procedure CheckForCarDirectErrors
as
  set nocount on;

	declare @MsgBody varchar(max)
	exec GetCardDirectErrorMessage @MsgBody output

	if @MsgBody is null or rtrim(@MsgBody) = ''
	  return;

	DECLARE	@return_value int, @MsgSubject varchar(50), @MsgId int

	declare @DistrutionList varchar(max) = 'CardDirect@example.com; aibarra@example.com'

	declare @Emails table (email varchar(120)) 
	declare @Mail varchar(120)

	insert into @Emails
	  select *
	  from WireSearch.dbo.Split2(@DistrutionList)

	declare curEmails cursor for 
	  select email from @Emails

	Set @MsgSubject = 'Alert CardDirect Errors'

  Open curEmails;

  while 1=1
  begin
    FETCH NEXT FROM curEmails INTO @Mail
    IF @@FETCH_STATUS <> 0
      Break;
    
	EXEC	@return_value = WireSearch.dbo.SendEmail
			@SenderEmail = 'italert@example.com',
			@SenderName = 'System Alert',
			@Email = @Mail,
			@EmailCc = '',
			@Subject = @MsgSubject,
			@MsgBody = @MsgBody,
			@Tag = '2',
			@MsgId = @MsgId OUTPUT

   end

  Close curEmails;
  deallocate curEmails;
    
--SELECT	@MsgId as N'@MsgId'