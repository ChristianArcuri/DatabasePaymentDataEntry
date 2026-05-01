
CREATE PROCEDURE [dbo].[ImxDirect_WIRE_CFPBLogSave_v3]
	@PreparationId uniqueidentifier,
	@CurrentLanguageId int,
	@AgSenderCode CHAR(10),
	@SenderId int,
	@ReceiverId int,
	@OriCurrencyCode varchar(3),
	@AmountToBeTransferred MONEY,
	@FrontEndFee MONEY,
	@Taxes MONEY,
	@ExchangeRate MONEY,
	@BackEndFeeTaxes MONEY,
	@TotalAmountToBeReceived MONEY,
	@DestCurrencyCode varchar(3),
	@AgPayerCode CHAR(10),
	@BranchId int,
	@AgentName VARCHAR(150),
	@SenderName VARCHAR(150),
	@Action CHAR(10),
	@UserName VARCHAR(15) ,
	@LogResult int OUTPUT,--0 ok, 1 error de validacion, 500 error inesperado
	@ErrorCode varchar(10) OUTPUT,
	@LogErrorMessage varchar(max) OUTPUT,
	@UserErrorMessage varchar(300) OUTPUT
AS
BEGIN  

BEGIN TRY

  SET @LogResult =0
  SET @ErrorCode ='' 
  SET @LogErrorMessage ='' 
  SET @UserErrorMessage =''

    IF EXISTS (Select 1 FROM ImxDirect_WireCFPBLog Where PreparationId = @PreparationId)
	     BEGIN
		   UPDATE ImxDirect_WireCFPBLog SET SenderId = @SenderId
										   ,ReceiverId = @ReceiverId
										   ,WireDatetime = getdate()
										   ,AmountToBeTransferred = @AmountToBeTransferred
										   ,FrontEndFee = @FrontEndFee
										   ,Taxes = @Taxes
										   ,ExchangeRate = @ExchangeRate
										   ,BackEndFeeTaxes  = @BackEndFeeTaxes
										   ,TotalAmountToBeReceived = @TotalAmountToBeReceived
										   ,AgPayerCode = @AgPayerCode
										   ,AgSenderCode = @AgSenderCode
										   ,BranchId = @BranchId
										   ,AgentName = @AgentName
										   ,SenderName = @SenderName
										   ,Action = @Action
										   ,UserName = @UserName
										   ,OriCurrencyCode = @OriCurrencyCode
										   ,DestCurrencyCode = @DestCurrencyCode
			WHERE PreparationId = @PreparationId
	     END
	ELSE BEGIN
			INSERT INTO ImxDirect_WireCFPBLog with(rowlock)
					   (PreparationId
					  ,SenderId
					  ,ReceiverId
					  ,WireDatetime
					  ,AmountToBeTransferred
					  ,FrontEndFee
					  ,Taxes
					  ,ExchangeRate
					  ,BackEndFeeTaxes
					  ,TotalAmountToBeReceived
					  ,AgPayerCode
					  ,AgSenderCode
					  ,BranchId
					  ,AgentName
					  ,SenderName
					  ,Action
					  ,UserName
					  ,OriCurrencyCode
					  ,DestCurrencyCode)
				 VALUES (@PreparationId
					  ,@SenderId
					  ,@ReceiverId
					  ,getdate()
					  ,@AmountToBeTransferred
					  ,@FrontEndFee
					  ,@Taxes
					  ,@ExchangeRate
					  ,@BackEndFeeTaxes
					  ,@TotalAmountToBeReceived
					  ,@AgPayerCode
					  ,@AgSenderCode
					  ,@BranchId
					  ,@AgentName
					  ,@SenderName
					  ,@Action
					  ,@UserName
					  ,@OriCurrencyCode
					  ,@DestCurrencyCode)  
		END


END TRY
BEGIN CATCH
  SET @LogErrorMessage  = ERROR_MESSAGE()
    if @@TRANCOUNT > 0
      rollback TRAN;
	SET @LogResult    = 500
	SET @ErrorCode = '11283' -- An Anexpected error has occurred, please try again and if the error persists contact technical support
	SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
END CATCH
END