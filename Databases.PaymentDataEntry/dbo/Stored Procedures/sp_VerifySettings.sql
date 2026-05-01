CREATE PROCEDURE [dbo].[sp_VerifySettings] (@UserName varchar(15), @Password varchar(10), 
                                    @AgencyCode varchar(10), @AgInstallationKey varchar(15),
                                    @Result varchar(80) output)
AS
BEGIN
  set nocount on;
  
  DECLARE @R_Psw varchar(40)
  Set @Result = ''
  SELECT @R_Psw = UserPass   
  FROM  WireSecurity.dbo.Sec_AppUsers 
  WHERE  (UserName = @UserName) AND UserStatus = 'A'
         
  IF @R_Psw IS null
    BEGIN
      SET @Result = 'User Name no existe.'
      RETURN
    END
  IF @R_Psw <> @Password
    BEGIN
      SET @Result = 'Password incorrecto.'
      RETURN
    END
  SELECT @R_Psw = AgInstallationKey 
    FROM WireSearch.dbo.Agencies 
   WHERE AgencyCode = @AgencyCode
  IF @R_Psw IS null
    BEGIN
      SET @Result = 'Agencia no existe.'
      RETURN
    END
  IF @R_Psw <> @AgInstallationKey
     SET @Result = 'Codigo de Agencia Incorrecto'
END
