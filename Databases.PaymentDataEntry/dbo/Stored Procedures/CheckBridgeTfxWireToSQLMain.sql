CREATE procedure CheckBridgeTfxWireToSQLMain
as
  set nocount on;

declare @D datetime

Set @D = DateAdd(day, -1, dbo.DateOnly(GetDate()))

---declare @MissingWires table (WireId int)

declare curWireChk cursor for
	select T1.WireID, AgSenderCode, AgSenderSeq
	from dbo.ProcessedWires T1
	  join Wires T2 ON T1.WireID = T2.WireId 
	where WireDate >= @D and 
	      Done = 1 and WireChk = 0 and 
	      not Exists(select * from dbo.WirePossibleFraud T01 where T01.WireId = T1.WireID and T01.Ok = 0)

declare @Wireid int, @AgSenderCode varchar(20), @AgSenderSeq int

  Open curWireChk
  
  while 1=1
  begin
    FETCH NEXT FROM curWireChk INTO @Wireid, @AgSenderCode, @AgSenderSeq;
    if @@FETCH_STATUS <> 0
      Break;
     
    if Exists(select * from SQLMAIN.WireTransac.dbo.Wires where AgSenderCode = @AgSenderCode and AgSenderSeq = @AgSenderSeq)
      begin
        update dbo.ProcessedWires with(updlock) 
           set WireChk = 1 
        where WireID = @Wireid
      end
    else
      begin
--        insert into @MissingWires (WireId) values(@Wireid)
        update dbo.ProcessedWires with(updlock) 
           set Done = 0 
        where WireID = @Wireid
      end
    
  end
  
  Close curWireChk
  Deallocate curWireChk
  
  
  