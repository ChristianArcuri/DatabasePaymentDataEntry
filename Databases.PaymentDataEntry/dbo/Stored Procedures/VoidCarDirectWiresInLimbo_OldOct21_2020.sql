CREATE procedure [dbo].[VoidCarDirectWiresInLimbo_OldOct21_2020]
as
  set nocount on;

	declare @D datetime, @WireId int

	Set @D = DATEADD(minute, -12, GetDate())

	declare curCardirectLostWires cursor for
		select WireId
		from Wires T1
		where SenderPaymentMethodId = 5
			 and not Exists(select * from ProcessedWires T01 where T01.WireID = T1.WireId)
			 and T1.WireDatetime <= @D

	open curCardirectLostWires;

    while 1=1
	begin
	  fetch next from curCardirectLostWires into @WireId;
	  if @@FETCH_STATUS <> 0
	    break;
		
--	  begin tran;
        print @WireId
	    exec CardDirect_VoidWire @WireId
--	  commit tran;	  
	end

	close curCardirectLostWires;
	Deallocate curCardirectLostWires;
