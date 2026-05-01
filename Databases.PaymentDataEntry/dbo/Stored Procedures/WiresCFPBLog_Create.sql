CREATE PROCEDURE [dbo].[WiresCFPBLog_Create]
	@WireTAG char(15),
	@SenderId int,
	@ReceiverId int,
	@WireDatetime DATETIME,
	@AmountToBeTransferred MONEY,
	@FrontEndFee MONEY,
	@Taxes MONEY,
	@ExchangeRate MONEY,
	@BackEndFeeTaxes MONEY,
	@TotalAmountToBeReceived MONEY,
	@AgPayerCode CHAR(10),
	@AgSenderCode CHAR(10),
	@BranchId int,
	@AgentName VARCHAR(150),
	@SenderName VARCHAR(150),
	@AgSenderSeq int,
	@Action CHAR(10),
	@UserName VARCHAR(15) 
AS
BEGIN  
	INSERT INTO WiresCFPBLog with(rowlock)
			   (WireTAG
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
			  ,AgSenderSeq
			  ,Action
			  ,UserName)
		 VALUES (@WireTag
			  ,@SenderId
			  ,@ReceiverId
			  ,@WireDatetime
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
			  ,@AgSenderSeq
			  ,@Action
			  ,@UserName)  
			     
	RETURN SCOPE_IDENTITY()
END