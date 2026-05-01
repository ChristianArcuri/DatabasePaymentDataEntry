CREATE procedure [dbo].[VerifyToken] 
   @Token varchar(200),
   @WireAgSenderCode varchar(20),
   @WireAgPayerCode varchar(20),
   @Result int output, 
   @Delay int output --Time between the token generation and the call to the sp
as
--- @Result values:
--- 1 .- Invalid AgSender, Payer info or not provided
--- 2 .- Invalid Token length
--- 3 .- not a valid time stamp
--- 4 .- Timeout - The Token time expired
--- 5 .- invalid Sending agency or it is not active
--- 6 .- invalid payer or not active
--- 7 .- Invalid Token or not supplied
--- 8 .- Agency in wire and in token are not the same
--- 9 .- Payer in wire and in token are not the same
  set nocount on;
     
  declare @PaddingSize int = 6
  declare @FToken char(2), @Data char(14)
  declare @YY char(4), @MM char(2), @DD char(2), @HH char(2), @NN char(2), @SS char(2)
  declare @TokenInStr varchar(50), @TokenIn datetime, @TokenNow datetime
  declare @PipePos int, @SemiColonPos int, @AgSenderCode varchar(20), @AgPayerCode varchar(20)

  Set @Result = 0
  Set @Delay = 1  ---------------
  return    --------------------
/*  
  select @Token = WireKeys.dbo.DecryptToken(@Token)
  
  if @Token = ''
   begin
     Set @Result = 7 --Invalid Token
     Return
   end
  
  select @PipePos = CHARINDEX( '|', @Token), @SemiColonPos = CHARINDEX(';', @Token)
  
  if @PipePos = 0 or @SemiColonPos = 0
   begin
     Set @Result = 1 --Invalid AgSender, Payer info
     Return
   end
   
  select @AgSenderCode = rtrim(SUBSTRING(@Token, @PipePos + 1,  @SemiColonPos - @PipePos - 1)),
         @AgPayerCode = rtrim(SUBSTRING(@Token, @SemiColonPos + 1, 20))

  Set @Token = SUBSTRING(@Token, 1, @PipePos - 1)
  
  if LEN(@Token) <> 28
   begin
     Set @Result = 2 --Invalid len
     return 
   end
   
  Set @Token = SUBSTRING(@Token, @PaddingSize + 1, LEN(@Token))
  Set @FToken = SUBSTRING(@Token, 1, 2)
  
  if @FToken = '34'
    Set @Data = SUBSTRING(@Token, 3, 14) 
  else if @FToken = '95'  
    Set @Data = Right(@Token, 14)
    
  select @YY = SUBSTRING(@Data, 1, 4), @MM = SUBSTRING(@Data, 5, 2), @DD = SUBSTRING(@Data, 7, 2), 
         @HH = SUBSTRING(@Data, 9, 2), @NN = SUBSTRING(@Data, 11, 2), @SS = SUBSTRING(@Data, 13, 2)

  Set @TokenInStr = (@MM + '/' + @DD + '/' + @YY + ' ' + @HH + ':' + @NN + ':' + @SS)
  
  if ISDATE(@TokenInStr) = 1
   begin
    Set @TokenIn = CAST(@TokenInStr as DateTime)
   end
  else
   begin
     Set @Result = 3 --not a valid time stamp
     Return
   end  
    
  Set @Delay = DATEDIFF(second, @TokenIn, GETDATE()) 
  
  if @Delay > 30 
   begin 
    Set @Result = 4 --Timeout
    Return
   end 
  
  if not Exists(select * from WireSearch.dbo.Agencies with(nolock) where AgencyCode = @AgSenderCode and AgSender = 1 and AgSenderStatus in ('A', 'S'))
   begin
     Set @Result = 5 --invalid agency or not active
     Return
   end
      
  if not Exists(select * from WireSearch.dbo.Agencies with(nolock) where AgencyCode = @AgPayerCode and AgPayer = 1 and AgPayerStatus in ('A', 'S'))
   begin
     Set @Result = 6 --invalid payer or not active
     Return
   end
  
  if rtrim(@WireAgSenderCode) <> @AgSenderCode 
   begin
     Set @Result = 8 --Agency in wire and in token are not the same
     Return
   end
  
  if rtrim(@WireAgPayerCode) <> @AgPayerCode
   begin
     Set @Result = 9 --Payer in wire and in token are not the same
     Return
   end
  */
--  select GETDATE() as Now, DATEDIFF(second, @TokenIn, GETDATE()) 
           
  --select @Token, @FToken, @Data, @AgSenderCode, @AgPayerCode, @Result, @Delay
  