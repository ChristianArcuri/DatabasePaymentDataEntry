create FUNCTION [dbo].[fn_IsAgUserPswOk] (@AgencyCode varchar(20), @UserName varchar(50), @PswHash varbinary(32))
RETURNS bit
AS
BEGIN
   DECLARE @R bit

   if (select COUNT(*) 
        from WireSearch.dbo.ViewAgenciesLogins
        where AgencyCode = @AgencyCode and UserName = @UserName and PswHash = @PswHash) > 0
	  Set @R = 1
   else
      Set @R  = 0	  	  
		  
  Return @R;
END