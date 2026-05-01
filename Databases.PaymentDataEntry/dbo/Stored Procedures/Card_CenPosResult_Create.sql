
create PROCEDURE [dbo].[Card_CenPosResult_Create] 
	@WireTAG varchar(20),
	@AuthCode varchar(20),
	@Amount decimal(18,2),
	@Donation decimal(18,2),
	@OriginalAmount decimal(18,2),
	@CardType varchar(50),
	@CardNumber varchar(30),
	@IsCommercialCard bit,
	@NameOnCard varchar(100),
	@Email varchar(100),
	@EntryMethod varchar(30),
	@ReferenceNumber bigint,
	@TraceNumber varchar(50),
	@ResponseResult varchar(10),
	@ResponseMessage varchar(2000),
	@ProcessAs varchar(30),
	@SessionId varchar(50),
	@Token varchar(50),
	@Operation varchar(30),
	@Signature varchar(30),
	@ResultId int OUTPUT
AS
BEGIN


	INSERT INTO dbo.Card_CenPosResults
			   (WireTAG
			   ,AuthCode
			   ,Amount
			   ,Donation
			   ,OriginalAmount
			   ,CardType
			   ,CardNumber
			   ,IsCommercialCard
			   ,NameOnCard
			   ,Email
			   ,EntryMethod
			   ,ReferenceNumber
			   ,TraceNumber
			   ,ResponseResult
			   ,ResponseMessage
			   ,ProcessAs
			   ,SessionId
			   ,Token
			   ,Operation
			   ,[Signature]
			   ,Created)
		 VALUES
			   (@WireTAG
			   ,@AuthCode
			   ,@Amount
			   ,@Donation
			   ,@OriginalAmount
			   ,@CardType
			   ,@CardNumber
			   ,@IsCommercialCard
			   ,@NameOnCard
			   ,@Email
			   ,@EntryMethod
			   ,@ReferenceNumber
			   ,@TraceNumber
			   ,@ResponseResult
			   ,@ResponseMessage
			   ,@ProcessAs
			   ,@SessionId
			   ,@Token
			   ,@Operation
			   ,@Signature
			   ,GETDATE())


	SET @ResultId = SCOPE_IDENTITY()
END
