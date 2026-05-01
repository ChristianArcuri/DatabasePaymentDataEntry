CREATE PROCEDURE [dbo].[DataMaintenance_DataEntry]
AS
BEGIN
  SET NOCOUNT ON;

 delete from Wires 
 where WireID in (select top 250000 T1.WireID 
                  from Wires T1, ProcessedWires T2
                  where T1.WireID = T2.WireID and Done = 1 AND
                        WireDate <= dbo.DateOnly(GetDate() - 7) 
                  order by T1.WireId)

 delete from Senders 
 where LSenderid not in (select LSenderID from Wires)

 delete from Receivers 
 where LReceiverid not in (select LReceiverid from Wires)

 delete from ProcessedWires
 where Wireid not in (select Wireid from Wires)
 
 
 ------------------Compliance------------------------
 delete from WireCompliance.dbo.Comp_WireOnHoldHits
 where OnHoldRecordID in 
			 (select Wireid 
			  from WireCompliance.dbo.Comp_WireOnHold
			  where Wireid not in (select Wireid from Wires))
 
 delete from WireCompliance.dbo.Comp_WireOnHold
 where Wireid not in (select Wireid from Wires)

 
 delete from WireCompliance.dbo.LogAmountWarnMsg where MsgDate <= (GetDate() - 32) and Processed = 1
   
END
