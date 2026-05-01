create procedure InsQA_OTP 
     @AgencyCode varchar(20), @AgComputerName varchar(50), 
	 @AgComputerTime datetime, @OTPRefTime datetime
as
  set nocount on;

  insert into QA_OTP with(rowlock) (AgencyCode, AgComputerName, AgComputerTime, OTPRefTime)
  values(@AgencyCode, @AgComputerName, @AgComputerTime , @OTPRefTime)

