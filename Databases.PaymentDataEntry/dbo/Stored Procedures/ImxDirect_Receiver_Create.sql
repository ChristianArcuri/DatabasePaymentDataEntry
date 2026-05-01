CREATE PROCEDURE dbo.ImxDirect_Receiver_Create
	@CurrentLanguageId  INT,
	@RcvAddress 		Varchar(200),
	@RcvCity 			Varchar(60),                          
	@RcvCountryAbbr		VARCHAR(3),           
	@RcvFirstName 		Varchar(50),          
	@RcvLast1 			Varchar(50),             
	@RcvLast2 			Varchar(50),             
	@RcvPhone 			Varchar(20),             
	@RcvState 			Varchar(40),              
	@RcvZip 			Varchar(15),  
	@Username			VARCHAR(15),
	@NoSecLastName		BIT,
	@Cpf 				Varchar(11),
	@Result             INT=0 OUTPUT,
	@ErrorCode          VARCHAR(10) OUTPUT,
	@UserErrorMessage   varchar(300) OUTPUT,
	@LogErrorMessage    varchar(MAX) OUTPUT,
	@ReceiverId           INT=0 OUTPUT,
	@RcvVersionId       INT=0 OUTPUT,
	@ReceiverGroupId      INT=0 OUTPUT

AS
BEGIN
  DECLARE @RcvCountry VARCHAR(30)
  SET @Result  = 0

  SELECT @RcvCountry= CountryName
    FROM WireSearch.dbo.Geo_Countries
   WHERE CountryAbbr = @RcvCountryAbbr
   
   BEGIN TRY
	 EXEC SqlMain.WireTransac.dbo.Partners_Receivers_Create
		   	@pI_EnteredBy			= @Username,
			@pI_RcvFirstName		= @RcvFirstName,
			@pI_RcvLast1			= @RcvLast1,
			@pI_RcvLast2			= @RcvLast2,
			@pI_RcvAddress			= @RcvAddress,
			@pI_RcvCountry			= @RcvCountry,
			@pI_RcvState			= @RcvState,
			@pI_RcvCity				= @RcvCity,
			@pI_RcvZip				= @RcvZip,
			@pI_RcvPhone			= @RcvPhone,
			@pI_NoSecLastName		= @NoSecLastName,
			@pI_ShowOnCreateWire	= 1,
			@pI_CPF                 = @Cpf,
			@pO_ReceiverId          = @ReceiverId OUTPUT,
			@pO_RcvLastVersionId    = @RcvVersionId OUTPUT,
	 		@pO_RcvGroupId			= @ReceiverGroupId OUTPUT
 END TRY
 BEGIN CATCH
    SET @LogErrorMessage  = ERROR_MESSAGE()
	SET @Result    = 500
	SET @ErrorCode = '10950' -- Error saving the Receiver Information
	SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)

 END CATCH  

END
GO

