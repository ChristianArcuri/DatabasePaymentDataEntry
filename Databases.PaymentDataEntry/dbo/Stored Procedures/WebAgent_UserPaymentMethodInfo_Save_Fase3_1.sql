CREATE PROCEDURE [dbo].[WebAgent_UserPaymentMethodInfo_Save_Fase3_1]
@UserPaymentMethodInfoId int OUTPUT,
@WebAgentUserId int,
@StateFrom varchar(40), --New
@ChannelId int,         --New
@CurrentWebLanguageId int,
@SenderPaymentMethodId int,
@AbaCode varchar(9),
@AccountNumber varchar(20),
@AccountType char(1),
@AcculynkToken  varchar(20),   
@NameOnTheCard varchar(150), --New fase 3.1
@CardTypeCode varchar(3), 
@LastFourOfCard varchar(4), 
@PinElegible bit,           
@CardNumCopyPaste bit,
@BankAccountVerifiedOK bit ,
@StatementAddress varchar(100),
@StatementCountry varchar(30), 
@statementState varchar(30),
@StatementCity varchar(40), 
@StatementZipCode varchar(15),
@AccVerifResult varchar(10),
@UpdResult int OUTPUT,
@ErrorCode  varchar(10) OUTPUT,
@UserErrorMessage varchar(300) OUTPUT,
@LogErrorMessage varchar(MAX) OUTPUT

--No pisar cuentas de banco

AS
BEGIN

  DECLARE @LegalEntityCode varchar(10)
  DECLARE @ValidResult int

  SET @UpdResult = 2
  SET @ErrorCode = ''
  SET @UserErrorMessage = ''
  SET @LogErrorMessage = ''

  IF @WebAgentUserId = 0
     BEGIN
	   SET @ErrorCode = '10802'  --Usuario no puede ser 0
	   SET @UpdResult = 2
       SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage ('10810',@CurrentWebLanguageId) --Unable to Save Payment Information at this time, Plese try again later
	   RETURN
	 END

  IF @SenderPaymentMethodId = 0
     BEGIN
	   SET @ErrorCode = '10801'  --El metodo de pago no puede estar en 0
	   SET @UpdResult = 2
       SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage ('10810',@CurrentWebLanguageId) --Unable to Save Payment Information at this time, Plese try again later
	   RETURN
	 END



  
	

  IF @SenderPaymentMethodId = 2 --ACH
     BEGIN
	   --Agregar validacion de minima cantidad de digitos para cuentas
	   IF rtrim(@AccountNumber) = ''
		 BEGIN
		   SET @ErrorCode = '10803'  --La Cuenta de Banco no puede ser blanco
		   SET @UpdResult = 1
		   SET @UserErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebLanguageId)
		   SET @LogErrorMessage   = ''
		   RETURN
		 END
	   IF rtrim(@AbaCode) = ''  
		  BEGIN
			SET @ErrorCode = '10804' --El ABA no puede estar en vacio
			SET @UpdResult = 1
	        SET @UserErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebLanguageId)
	        SET @LogErrorMessage   = ''
			RETURN
		  END

		--  insert into debug (str,value) values(@AccountType,@AccountNumber)
	   IF (@AccountType IS NULL)
	   OR (rtrim(@AccountType) = '')
	   OR (rtrim(@AccountType) NOT IN( 'S','C'))
		  BEGIN
			SET @ErrorCode = '10805'  --Tipo de cuenta invalido
			SET @UpdResult = 1
	        SET @UserErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebLanguageId)
	        SET @LogErrorMessage   = ''
			RETURN
		  END

        DECLARE @ValidResultOK int
        EXEC WireSearch.dbo.GIACT_ValidateAccountNumber @WebAgentUserId ,@CurrentWebLanguageId ,
		                                                @AccountNumber,@AbaCode,
														@ValidResultOK OUTPUT,@ErrorCode OUTPUT,
														@UserErrorMessage OUTPUT,@LogErrorMessage OUTPUT
        IF @ValidResultOK = 0
		   BEGIN
		     SET @UpdResult = 1
		     RETURN
		   END
		ELSE SET @AccVerifResult = 'OK'

		IF EXISTS (Select * FROM SqlMain.WireTransac.dbo.WebAgent_UserPaymentMethodInfo
		            Where SenderPaymentMethodId     = 2
					  and AbaCode                   = @AbaCode
					  and AccountNumber             = @AccountNumber
					  and SenderPaymentMethodStatus = 'D')
			BEGIN
			  SET @ErrorCode = '10945'  --This account number cannot be accepted. Please, for more information contact support at 1-800-
			  SET @UpdResult = 1
	          SET @UserErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebLanguageId)
	          SET @LogErrorMessage   = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebLanguageId)+' aba '+@AbaCode+' account '+@AccountNumber
			  RETURN 
			END

		DECLARE @UsersSameAccount int
		SELECT @UsersSameAccount = COUNT(DISTINCT webagentuserid)
		  FROM SqlMain.WireTransac.dbo.WebAgent_UserPaymentMethodInfo
		 Where SenderPaymentMethodId     = 2
		   and AbaCode                   = @AbaCode
		   and AccountNumber             = @AccountNumber
		   and WebAgentUserId           <> @WebAgentUserId
		   and SenderPaymentMethodStatus = 'A'
		IF @UsersSameAccount > 3
		   BEGIN
		     SET @ErrorCode = '10945'  --This account number cannot be accepted. Please, for more information contact support at 1-800-
			 SET @UpdResult = 1
	         SET @UserErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebLanguageId)
	         SET @LogErrorMessage   = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebLanguageId)+' aba '+@AbaCode+' account '+@AccountNumber
			 RETURN
		   END

	 END
  IF @SenderPaymentMethodId in (3,4)
     BEGIN
	   IF (@AcculynkToken IS NULL)
	   OR (rtrim(@AcculynkToken) = '')
	      BEGIN
		    SET @ErrorCode = ''  
			SET @UpdResult = 1
	        SET @UserErrorMessage  = ''
	        SET @LogErrorMessage   = 'Please generate the Acculynk token first'
			RETURN
		  END
	   IF (@CardTypeCode IS NULL)
	   OR (@CardTypeCode = '')
	       BEGIN
		    SET @ErrorCode = ''  
			SET @UpdResult = 1
	        SET @UserErrorMessage  = ''
	        SET @LogErrorMessage   = 'Card type code cannot be blank'
			RETURN
		   END
	   IF (@LastFourOfCard IS NULL)
	   OR (rtrim(@LastFourOfCard) = '')
	      BEGIN
		    SET @ErrorCode = ''  
			SET @UpdResult = 1
	        SET @UserErrorMessage  = ''
	        SET @LogErrorMessage   = 'Last 4 digits of the card cannot be blank'
			RETURN
		  END
	  IF (@PinElegible IS NULL)
	      BEGIN
		    SET @ErrorCode = ''  
			SET @UpdResult = 1
	        SET @UserErrorMessage  = ''
	        SET @LogErrorMessage   = 'Pin elegible cannot be null'
			RETURN
		  END

	   EXEC  WireSearch.dbo.WebAgent_ValidSimilarName @WebAgentUserId,@CurrentWebLanguageId,@NameOnTheCard,
             @ValidResult  OUTPUT, --0 = ok , 1 = Not match
			 @ErrorCode OUTPUT,@UserErrorMessage  OUTPUT,@LogErrorMessage  OUTPUT
       IF @ValidResult = 1
	      BEGIN
	        SET @UpdResult = 1
			RETURN
		  END
	 END

  EXEC WireSearch.dbo.WebAgent_GetLegalEntity @ChannelId ,@CurrentWebLanguageId ,@StateFrom ,@LegalEntityCode  OUTPUT,@ErrorCode OUTPUT
  IF @ErrorCode <> ''
  BEGIN	   
	   SET @UpdResult = 1
	   SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)+rtrim(@StateFrom)	   
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebLanguageId)
	   RETURN
	 END
--insert into  debug (str,value) values(@LEgalEntityCode,@StateFrom)
   IF (@SenderPaymentMethodId = 2)
      BEGIN
		  IF (@UserPaymentMethodInfoId = 0) --Si viene en 0 y ya existe
			   BEGIN
				  SELECT @UserPaymentMethodInfoId = UserPaymentMethodInfoId
					FROM SqlMain.WireTransac.dbo.WebAgent_UserPaymentMethodInfo
				   WHERE WebAgentUserId        = @WebAgentUserId
					 AND SenderPaymentMethodId = @SenderPaymentMethodId
					 AND AccountNumber         = @AccountNumber
					 AND AbaCode               = @AbaCode
					 AND SenderPaymentMethodStatus = 'A'
				   IF @@ROWCOUNT = 0
					  SET @UserPaymentMethodInfoId = 0
				END
		   ELSE BEGIN                       --Si no viene en 0 y no existe
		          IF NOT EXISTS (SELECT *
									FROM SqlMain.WireTransac.dbo.WebAgent_UserPaymentMethodInfo
								   WHERE WebAgentUserId        = @WebAgentUserId
									 AND SenderPaymentMethodId = @SenderPaymentMethodId
									 AND AccountNumber         = @AccountNumber
									 AND AbaCode               = @AbaCode
									 AND SenderPaymentMethodStatus = 'A')
                     SET @UserPaymentMethodInfoId = 0
		        END
		END

   IF (@SenderPaymentMethodId in (3,4))
  AND (@UserPaymentMethodInfoId > 0 )
     BEGIN
	   IF NOT EXISTS (SELECT *
						FROM SqlMain.WireTransac.dbo.WebAgent_UserPaymentMethodInfo
						WHERE WebAgentUserId        = @WebAgentUserId
						  AND SenderPaymentMethodId = @SenderPaymentMethodId
						  AND AcculynkToken         = @AcculynkToken
						  AND SenderPaymentMethodStatus = 'A')
			BEGIN
	          EXEC SqlMain.WireTransac.dbo.WebAgent_UserPaymentMethodInfo_Inactive @UserPaymentMethodInfoId,@WebAgentUserId
	          SET @UserPaymentMethodInfoId  = 0
		    END
	 END

IF @UserPaymentMethodInfoId = 0
       BEGIN
	      EXEC SqlMain.WireTransac.dbo.WebAgent_UserPaymentMethodInfo_Create_Fase3_1 @WebAgentUserId ,
		                                                                     @LegalEntityCode,
                                                                             @SenderPaymentMethodId ,
                                                                             @AbaCode ,
                                                                             @AccountNumber ,
                                                                             @AccountType ,
                                                                             @AcculynkToken ,   
																			 @NameOnTheCard,
																			 @CardTypeCode,   
																			 @LastFourOfCard,
																			 @PinElegible,
																			 @CardNumCopyPaste ,
                                                                             @BankAccountVerifiedOK  ,
                                                                             @StatementAddress ,
                                                                             @StatementCountry , 
                                                                             @statementState ,
                                                                             @StatementCity , 
                                                                             @StatementZipCode ,
                                                                             @AccVerifResult ,
                                                                             @UserPaymentMethodInfoId  OUTPUT
			IF (@UserPaymentMethodInfoId IS NOT NULL)
           AND (@UserPaymentMethodInfoId <> 0)
			  SET @UpdResult = 0
	     
	   END
  ELSE  BEGIN
			 EXEC SqlMain.WireTransac.dbo.WebAgent_UserPaymentMethodInfo_Update_fase3_1 @UserPaymentMethodInfoId ,
															@WebAgentUserId ,
															@SenderPaymentMethodId ,
															@AbaCode ,
															@AccountNumber ,
															@AccountType ,
															@AcculynkToken,  
															@NameOnTheCard,      
															@BankAccountVerifiedOK  ,
															@CardTypeCode ,
                                                            @LastFourOfCard , 
                                                            @PinElegible ,  
															@CardNumCopyPaste ,
															@StatementAddress,
															@StatementCountry , 
															@statementState ,
															@StatementCity , 
															@StatementZipCode ,
															@AccVerifResult ,
															@UpdResult  OUTPUT

            END


END