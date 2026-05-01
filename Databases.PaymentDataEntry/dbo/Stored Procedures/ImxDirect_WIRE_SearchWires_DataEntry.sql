CREATE PROCEDURE [dbo].[ImxDirect_WIRE_SearchWires_DataEntry]
    @CurrentLanguageId      int,
    @AgencyCode				VARCHAR(10),
	@QInProcessWires        INT= 0 OUTPUT,
	@SearchResult           INT =0  OUTPUT, --0 ok, 1 Error de validacion, 500 unexpected
	@ErrorCode varchar(10) OUTPUT,
	@UserErrorMessage varchar(300) OUTPUT,
    @LogErrorMessage varchar(MAX) OUTPUT

AS
BEGIN
	
	DECLARE @DateFrom datetime,
	        @DateTo   datetime

	SET @DateFrom = dbo.DateOnly(getdate())-7
	SET @DateTo   = dbo.DateOnly(getdate())

	SET @SearchResult       =    0   --0 ok, 1 Error de validacion, 500 unexpected
	SET @ErrorCode =''
	SET @UserErrorMessage =''
    SET @LogErrorMessage =''
	
	BEGIN TRY
	SELECT 		W.WireId, 
				W.SenderName,
				W.ReceiverName,
				W.AgSenderSeq,
				W.AgPayerCode,
				W.WireDatetime,
				w.OriAmount,
				w.OriCurrency,
				w.DestAmount,
				w.DestCountry,
				w.WireTotalAmount,
				W.DestCurrency,                        
				W.TranTypeID,
				W.DeliveryType,
				W.StsComplianceOk,
				W.StsCancel,
				W.CreatedBy,
				W.ReceiverId,
				W.SenderId,
				W.WireReplacementType,
				W.SourceApp,
				ISNULL(W.StsSenderPaymentOK, 0) as StsSenderPaymentOK,
				ISNULL(WASPM.SenderPaymentMethodName, '''') SenderPaymentMethodName,
				a.AgName as PayerName
		FROM Wires W
			 INNER JOIN Wiresearch.dbo.Agencies a ON a.AgencyCode = W.AgPayerCode AND a.AgPayer = 1
             INNER JOIN ProcessedWires as p on w.wireid = p.wireid and p.Done = 0
		     LEFT OUTER JOIN WireSearch.dbo.WebAgent_SenderPaymentMethods as WASPM on W.SenderPaymentMethodId = WASPM.SenderPaymentMethodid 
		WHERE w.AgSenderCode = @AgencyCode 
		   AND W.WireDate BETWEEN @DateFrom AND  @DateTo				 
	    ORDER BY WireId  DESC 

	    SET @QInProcessWires = @@ROWCOUNT

	 END TRY
	 BEGIN CATCH
	     SET @LogErrorMessage  =  'ImxDirect_WIRE_SearchWires_DataEntry - '+rtrim(@AgencyCode)+' - '+ERROR_MESSAGE()
	     SET @SearchResult = 500
		 SET @ErrorCode = '11257' --THERE WAS AN ERROR SEARCHING THE WIRES, PLEASE TRY AGAIN AND IF THE ERROR PERSISTS CALL TECHNICAL SUPPORT
		 SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) 
	 END CATCH
END