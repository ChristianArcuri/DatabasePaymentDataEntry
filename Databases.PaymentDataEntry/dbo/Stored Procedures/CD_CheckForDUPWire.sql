CREATE procedure CD_CheckForDUPWire
   @AgSenderCode varchar(10),
   @SenderName varchar(150),
   @ReceiverName varchar(150),
   @PossibleDUP bit output
as
  set nocount on;

  declare @Today datetime

  SET @Today = dbo.DateOnly(GetDate())

  if Exists(SELECT T1.WireId 
            FROM Wires T1
			  JOIN ProcessedWires T2 ON T1.WireId = T2.WireID
            WHERE AgSenderCode = @AgSenderCode
                      AND StsCancel    = 0 
                      AND WireDate     = @Today
                      AND SenderName   = @SenderName 
                      AND ReceiverName = @ReceiverName
					  AND not Exists(select Cancel from WireCompliance.dbo.Comp_CumulativeAmountsToday T01 where T01.WireID = T1.WireId and T01.Cancel = 1))
    begin
	  SET @PossibleDUP = 1
    end
  else
    begin
	  SET @PossibleDUP = 0
	end
