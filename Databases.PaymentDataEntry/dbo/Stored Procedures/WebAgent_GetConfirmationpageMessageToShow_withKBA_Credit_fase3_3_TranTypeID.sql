CREATE PROCEDURE [dbo].[WebAgent_GetConfirmationpageMessageToShow_withKBA_Credit_fase3_3_TranTypeID]
@ComplianceOk bit,
@StsFraudCheckOk bit,
@StsUserKBA int,
@StsCreditOK int, --New
@AvailabilityDate datetime,
@CurrentWebLanguageId int,
@TranTypeId int,
@MsgToShow varchar(max) OUTPUT
AS
BEGIN
  IF (@StsUserKBA in(0, 2) OR @StsCreditOK = 0) --Retenido x Lexis Nexis o Limite de Credito Llamar a Departamento de FLP
     BEGIN
	   IF @CurrentWebLanguageId = 1
	        SET @MsgToShow = 'Your Transaction was processed successfully. However, we need additional information before completing your wire transfer. Prease contact us by calling 1-866-999-3175' --Obtenerlo configurable
	   ELSE SET @MsgToShow = 'Tu Transacción ha sido procesada Exitosamente, sin embargo, se necesita información Adicional. Por favor, comunícate con soporte al 1-866-999-3175' --Obtenerlo configurable
	   RETURN
	 END
  
  IF @ComplianceOk = 0 -- Retenido x Compliance 
     BEGIN
	   IF @CurrentWebLanguageId = 1
	             SET @MsgToShow = 'Transaction successful. We''re processing your information and will notify you when the funds are available for pick-up. For questions contact 1-800-792-8017' --Obtenerlo configurable
	        ELSE SET @MsgToShow = 'Transacción exitosa, Estamos procesando tu informacion y te notificaremos en cuanto esté disponible para el cobro. Para preguntas, por favor contáctanos al 1-800-792-8017' --Obtenerlo configurable
            RETURN
	 END

	IF @StsFraudCheckOk = 0 --Retenido o Cybersource
	BEGIN
	   IF @CurrentWebLanguageId = 1
	             SET @MsgToShow = 'Transaction successful. We''re processing your information and will notify you when the funds are available for pick-up. For questions contact 1-800-792-8017' --Obtenerlo configurable
	        ELSE SET @MsgToShow = 'Transacción exitosa, Estamos procesando tu informacion y te notificaremos en cuanto esté disponible para el cobro. Para preguntas, por favor contáctanos al 1-800-792-8017' --Obtenerlo configurable
            RETURN
	 END

   --Esta todo OK
  IF @AvailabilityDate = dbo.DateOnly(getdate())
     BEGIN
	   IF @CurrentWebLanguageId = 1
	      BEGIN
	        SET @MsgToShow = 'Your Transaction was processed Successfully and  '
			IF @TranTypeId = 1
			     BEGIN
			       if  datepart(hh,getdate()) >= 9 --9:00 AM
				        SET @MsgToShow = rtrim(@MsgToShow)+' will be available for pick up in 20 minutes'
				   else SET @MsgToShow = rtrim(@MsgToShow)+' will be available for pick up Today'
				 END
			ELSE SET @MsgToShow = rtrim(@MsgToShow)+' funds will be available Today'
		  END
	   ELSE BEGIN
				SET @MsgToShow = 'Tu Transacción ha sido procesada Exitosamente y  '
				IF @TranTypeId = 1
				     BEGIN
					   if  datepart(hh,getdate()) >= 9 --9:00 AM
					        SET @MsgToShow = rtrim(@MsgToShow)+' estará disponible para recogerla en 20 minutos'
					   else SET @MsgToShow = rtrim(@MsgToShow)+' estará disponible para recogerla el dia de hoy'
					 END
				ELSE SET @MsgToShow = rtrim(@MsgToShow)+' los fondos estarán disponibles el dia de hoy'
	       END	    
	   RETURN
	 END
  ELSE BEGIN

       DECLARE @StrAvailabilityDate varchar(40)
	   SET @StrAvailabilityDate  = dbo.WebAgent_GetAvailabilityDateToShow(@AvailabilityDate,@CurrentWebLanguageId)
         IF @CurrentWebLanguageId = 1
	        BEGIN
		    	SET @MsgToShow = 'Your Transaction was processed Successfully and '
				IF @TranTypeId = 1
			         SET @MsgToShow = rtrim(@MsgToShow)+' will be available for pick on '+@StrAvailabilityDate
			    ELSE SET @MsgToShow = rtrim(@MsgToShow)+' the funds will be availabe on '+@StrAvailabilityDate
			END
	   ELSE BEGIn
	           SET @MsgToShow = 'Tu Transacción ha sido procesada Exitosamente y '
			   if @TranTypeId = 1
			        SET @MsgToShow = rtrim(@MsgToShow)+ ' estará disponible para recogerla el '+@StrAvailabilityDate
			   ELSE SET @MsgToShow = rtrim(@MsgToShow)+ ' los fondos estarán dispoibles el '+@StrAvailabilityDate
			END

       END
END