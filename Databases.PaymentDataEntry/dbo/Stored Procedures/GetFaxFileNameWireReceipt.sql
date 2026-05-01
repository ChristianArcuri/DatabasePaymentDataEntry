CREATE procedure [dbo].[GetFaxFileNameWireReceipt] (@AgSenderSeq int, @AgencyNo varchar(20), 
                                                   @FaxNumber varchar(15), @UserName varchar(20),
                                                   @ComputerName varchar(30),
                                                   @WRFileName varchar(1024) output)
AS                                                   
BEGIN 
  SET NOCOUNT ON;
  
  exec [SQLMISC].FaxOutgoing.dbo.GetFaxFileNameWireReceipt @AgSenderSeq,
                                                 @AgencyNo,
                                                 @FaxNumber,
                                                 @UserName,
                                                 @ComputerName,
                                                 @WRFileName output
END
