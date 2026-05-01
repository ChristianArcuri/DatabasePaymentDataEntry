CREATE PROCEDURE [dbo].[PayerAcumPopUpLog_Create]
@AgPayerCode VARCHAR(10),
@ReceiverName VARCHAR(150),
@WireAmount MONEY,
@AvailableAmount MONEY,
@OptionSelected CHAR(2),
@UserName varchar(15),
@SourceApp int,
@PayerAcumPopUpId INT OUTPUT
AS
BEGIN
  set  nocount on;
  
	INSERT INTO PayerAcumPopUpLog with(rowlock)
			   ([AgPayercode]
			   ,[ReceiverName]
			   ,[WireAmount]
			   ,[AvailableAmount]
			   ,[OptionSelected]
			   ,[CreatedBy]
			   ,[SourceApp])
		 VALUES (@AgPayerCode,
				 @ReceiverName,
				 @WireAmount,
				 @AvailableAmount,
				 @OptionSelected,
				 @UserName,
				 @SourceApp)
				 
     SET @PayerAcumPopUpId = SCOPE_IDENTITY()        
END