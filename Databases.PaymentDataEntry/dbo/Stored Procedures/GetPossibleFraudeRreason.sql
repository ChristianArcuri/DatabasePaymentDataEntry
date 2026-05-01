CREATE procedure GetPossibleFraudeRreason @WireId int, @Result varchar(max) output
as
  set nocount on;
  
   declare @InvalidUser bit = 0, @WrongPassword bit = 0, @WrongAppHash bit = 0,
           @InvalidConnectionUser bit = 0, @ComputerNotAuth bit = 0, @InvalidSPToken bit = 0,
           @NoLogin bit = 0, @AgencyCode varchar(20), @AgSenderSeq int

	select @AgencyCode = T2.AgSenderCode, @AgSenderSeq = T2.AgSenderSeq,
	       @InvalidUser = InvalidUser, @WrongPassword = WrongPassword, @WrongAppHash = WrongAppHash, 
		   @InvalidConnectionUser = InvalidConnectionUser, @ComputerNotAuth = ComputerNotAuth, 
		   @InvalidSPToken = InvalidSPToken, @NoLogin = NoLogin 
	from dbo.WirePossibleFraud T1
	  join Wires T2 ON T1.WireId = T2.WireId
	where T1.WireId = @WireId
   
   Set @Result = ''
   
   if @InvalidUser <> 0
     Set @Result = 'Invalid user, '

   if @WrongPassword <> 0
     Set @Result = @Result + 'Wrong Password, ' 
     
   if @WrongAppHash <> 0
     Set @Result = @Result + 'Wrong App. Hash, ' 
     
   if @InvalidConnectionUser <> 0
     Set @Result = @Result + 'Invalid User Connection, ' 

   if @ComputerNotAuth <> 0
     Set @Result = @Result + 'Computer not authorized, ' 

   if @InvalidSPToken <> 0
     Set @Result = @Result + 'Invalid SP. call Token, ' 
   
   if @NoLogin <> 0
     Set @Result = @Result + 'Not valid login found, ' 
   
   if @Result <> ''
     Set @Result = 'Agency: ' + RTRIM(@AgencyCode) + ' Wire Seq.: ' + CAST(@AgSenderSeq as varchar) + ' Error: ' + SUBSTRING(@Result, 1, len(@Result) - 1)
     
     