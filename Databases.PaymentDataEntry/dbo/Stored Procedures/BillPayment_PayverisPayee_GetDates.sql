
CREATE PROCEDURE BillPayment_PayverisPayee_GetDates 
	@UserProfileId varchar(50),
	@PayeeId bigint OUTPUT,
	@NextAvailableProcessingDate datetime OUTPUT,
	@NextAvailableDeliveryDate datetime OUTPUT,
	@Result int OUTPUT -- 0 OK, 500 error
AS
BEGIN

	DECLARE @IsSuccessful bit
	DECLARE @InfoMessage varchar(max)
	DECLARE @ResultCode varchar(10)
	DECLARE @ResultMessage varchar(max)
	DECLARE @RequestData varchar(max)
	DECLARE @ResponseData varchar(max)
	DECLARE @RequestDate datetime
    DECLARE @LogId bigint
	DECLARE @PvAccountNumber varchar(30)
	DECLARE @PvBillerId bigint
	DECLARE @FinalBillerId bigint

	SET NOCOUNT ON;

	SET @Result = 0

	----Get payee if PayeeId is provided--------------------------
	IF ISNULL(@PayeeId, 0) > 0
		BEGIN
			SELECT @IsSuccessful  = IsSuccessful,
			    @ResultCode = CASE WHEN IsSuccessful = 1 THEN '0' ELSE '500' END,
			    @NextAvailableProcessingDate = NextAvailableProcessingDate,
			    @NextAvailableDeliveryDate = NextAvailableDeliveryDate
			FROM SqlCLR.dbo.BTPV_GetPayee (@UserProfileId, @PayeeId)
		END


END
