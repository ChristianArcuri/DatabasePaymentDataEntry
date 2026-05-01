
CREATE Function [dbo].[fnc_EcoMessage_withLanguage]
	(@MessageCode		Int,
	 @UserLanguageId    int)

	Returns Varchar(1000)
As
Begin

	Declare @ReturnValue			Varchar(300)


	Select Top 1 @ReturnValue = MessageText 
	  From WireSecurity.dbo.ConfigMessages
	 Where MessageCode  = @MessageCode	
	   And LanguageId	= @UserLanguageId


	Return @ReturnValue
End
