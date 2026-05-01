CREATE procedure [dbo].[PossibleFraudeCheck]
        @SPNo int, @WireId int, @AgCompID int, @ComputerName varchar(50), 
        @TokenValResult int, @AgencyCode varchar(20), @UserName varchar(20),
        @Token varchar(200), @PswHash varbinary(32), @PossibleFraud bit output
as
  set nocount on;
--select @WireId = 0, @AgCompID = 0, @TokenValResult = 0

  Set @PossibleFraud = 0
  
  declare @InvalidUser bit = 0, @WrongPassword bit = 0, @WrongAppHash bit = 0,
          @InvalidConnectionUser bit = 0, @ComputerNotAuth bit = 0, @InvalidSPToken bit = 0,
          @NoLogin bit = 0, @Ok bit
  
  -- UserName check
  if not Exists(select * from WireSearch.dbo.AgenciesLogins
                where AgencyCode = @AgencyCode and UserName = @UserName)
    set @InvalidUser = 1
    
  -- Password Check
  if dbo.fn_IsAgUserPswOk(@AgencyCode, @UserName, @PswHash) = 0                 
    set @WrongPassword = 1
    
  --Application Hash check 
  if dbo.fn_IsPayerTokenOk(@WireId) = 0
    set @WrongAppHash = 1 
    
  --Connection User check
  if suser_sname() not in ('CashDirectUsr', 'CashDirectUsrSecond2')
    set @InvalidConnectionUser = 1
  
  --Is computer authorized?  
  if (@AgCompID = 0 or @AgCompID is null) 
    Set @ComputerNotAuth = 1
    
  --SP token validation ok?  
  if @TokenValResult <> 0
    set @InvalidSPToken = 1  

  --A valid login must exists in the last 18 hrs    
  declare @DMinus16 datetime
  Set @DMinus16 = DATEADD(hour, -18, GETDATE())
  
  if Exists(select * from Wires T1
            where WireId = @WireId and
				   not Exists(select *
							  from WireSearch.dbo.LOG_AgenciesAppLogins T01
                                join WireSearch.dbo.AgencyComputers T02 ON T01.AgComputerId = T02.AgComputerId
							 where T01.AgencyCode = T1.AgSenderCode and 
								   T01.UserName = T1.CreatedBy and
								   T02.ComputerName = @ComputerName and
								   T01.Created >= @DMinus16)
							 )
     begin
       Set @NoLogin = 1 
     end

  if @WrongPassword = 1 or @WrongAppHash = 1 or @InvalidConnectionUser = 1 or 
     @ComputerNotAuth = 1 or @InvalidSPToken = 1 or @NoLogin = 1
   begin   
     Set @PossibleFraud = 1
     
     if @WrongPassword = 0 and @WrongAppHash = 0 and @InvalidConnectionUser = 0 and
        @ComputerNotAuth = 0 and @InvalidSPToken = 0 and 
        @NoLogin = 1
      begin  
        Set @Ok = 1
      end
     else
      begin
        select @Ok = 0
      end 
      
  --select @WrongPassword as WrongPassword, @WrongAppHash as WrongAppHash, @InvalidConnectionUser as InvalidConnectionUser, 
  --       @ComputerNotAuth as ComputerNotAuth, @InvalidSPToken as InvalidSPToken, @NoLogin as NoLogin    
     INSERT INTO dbo.WirePossibleFraud with(rowlock) 
			(WireId, TokenResult, S, Token, Ok,
			 InvalidUser, WrongPassword, WrongAppHash, InvalidConnectionUser, ComputerNotAuth, InvalidSPToken, NoLogin) 
	 VALUES(@WireId, @TokenValResult, @SPNo, @Token, @Ok,
			 @InvalidUser, @WrongPassword, @WrongAppHash, @InvalidConnectionUser, @ComputerNotAuth, @InvalidSPToken, @NoLogin)
   end
   