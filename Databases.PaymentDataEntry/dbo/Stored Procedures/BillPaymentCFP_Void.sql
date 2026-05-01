CREATE PROCEDURE [dbo].[BillPaymentCFP_Void]
	@BTControl int,
	@CurrentLanguageId int,
	@UserName varchar(15),
	@ConfirmationNumber varchar(30),
	@BTCancelReceiptMessage varchar(MAX),

	@VoidPaymentResult int OUTPUT,  -- 0 OK, 1 Was already cancelled, 500 error
	@ErrorCode varchar(10) OUTPUT,
	@UserErrorMessage varchar(300) OUTPUT,
	@LogErrorMessage varchar(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @BTAgSenderCode varchar(10)
	DECLARE @BTAgSenderId int
	DECLARE @BTAgPayerCode varchar(10)
	DECLARE @BTAgPayerId int
	DECLARE @BTSenderId int
	DECLARE @BTOriAmount money 
	DECLARE @BTOriCurrency char(3) 
	DECLARE @BTCharges money
	DECLARE @BTTaxAmount money 
	DECLARE @BTAgSenderCommission money 
	DECLARE @BTAgPayerCommission money 
	DECLARE @BTReferenceNumber bigint 
	DECLARE @BTAuthCode varchar(10) 
	DECLARE @BTStatus int
	DECLARE @BTStsCancel int
	DECLARE @BTEstPostDateTime datetime
	DECLARE @BTTransactionId uniqueidentifier
	DECLARE @UserProfileId varchar(50)	

    SELECT @BTAgSenderCode          = BTAgSenderCode,
			@BTAgSenderId           = BTAgSenderId,
			@BTAgPayerCode          = BTAgPayerCode,
			@BTAgPayerId            = BTAgPayerId,
			@BTSenderId				= BTSenderId,
			@BTOriAmount            = BTOriAmount,
			@BTOriCurrency          = BTOriCurrency,
			@BTCharges              = BTCharges,
			@BTTaxAmount            = BTTaxAmount,
			@BTAgSenderCommission   = BTAgSenderCommission,
			@BTAgPayerCommission    = BTAgPayerCommission,
			@BTReferenceNumber      = BTReferenceNumber,
			@BTAuthCode             = BTAuthCode,
			@BTStatus               = BTStatus,
			@BTStsCancel            = BTStsCancel,
			@BTEstPostDateTime      = BTEstPostDateTime,
			@BTTransactionId        = BTTransactionId
	FROM	SqlMain.WireTransac.dbo.BT_Sales 
	WHERE	BTControl = @BTControl

	IF @@ROWCOUNT = 0
	BEGIN
		SET @VoidPaymentResult = 500
		SET @ErrorCode = '' -- it should be defined
		SET @LogErrorMessage  = 'Transaction not found'
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
		RETURN
	END

	IF ISNULL(@BTStsCancel,0) <> 0
	BEGIN
		SET @VoidPaymentResult = 1 
		SET @ErrorCode = '' -- it should be defined
		SET @LogErrorMessage  = 'Transaction is already cancelled'
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
		RETURN
	END

	SELECT	*
	FROM	SqlMain.WireTransac.dbo.Comp_BillpaymentOnHold C 
			INNER JOIN SqlMain.WireTransac.dbo.Comp_BillpaymentOnHoldHits H ON C.OnHoldRecordID = H.OnHoldRecordID
	WHERE	C.BTControl = @BTControl
			AND H.ListType = 'E'

	IF @@ROWCOUNT > 0
	BEGIN
		SET @VoidPaymentResult = 500 
		SET @ErrorCode = '' -- it should be defined
		SET @LogErrorMessage  = 'Transaction cannot be cancelled due to it is on hold by compliance'
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
		RETURN
	END

	--SET @UserProfileId = @BTAgSenderCode + '_' + CONVERT(varchar,@BTSenderId)

	--DECLARE @InfoMessage varchar(max)
	--DECLARE @ResultCode varchar(10)
	DECLARE @AuthorizationCode varchar(30)

	SET @AuthorizationCode = CONVERT(varchar, @ConfirmationNumber)
	SET @VoidPaymentResult = 0

	IF (@BTStatus = 0)
	BEGIN
		UPDATE	SqlMain.WireTransac.dbo.BT_Sales 
		SET		BTStatus = 2 
		WHERE	BTControl = @BTControl

		SET @BTStatus = 2
	END
	
	EXEC SqlMain.WireTransac.dbo.BT_CFPSaleCancellation
			@BTControl ,
			'NBP', --TranType National Bill Payment
			@BTAgSenderCode,
			@BTAgSenderid,
			@BTAgPayerCode,
			@BTAgPayerid,
			@BTOriAmount,
			@BTOriCurrency,
			@BTCharges,
			@BTTaxAmount,
			@BTAgSenderCommission,
			@BTAgPayerCommission,
			@AuthorizationCode,
			0, --@ResultCode,
			'Successful', --@InfoMessage,
			@UserName,
			@BTStatus,
			@BTCancelReceiptMessage
END