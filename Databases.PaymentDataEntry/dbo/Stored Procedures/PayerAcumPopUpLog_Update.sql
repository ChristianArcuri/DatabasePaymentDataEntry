CREATE PROCEDURE [dbo].[PayerAcumPopUpLog_Update]
@PayerAcumPopUpId INT ,
@WireId INT
AS
BEGIN
  set  nocount on;
  
	UPDATE PayerAcumPopUpLog with(updlock) SET WireId = @WireId
	 WHERE PayerAcumPopUpId = @PayerAcumPopUpId
			       
END