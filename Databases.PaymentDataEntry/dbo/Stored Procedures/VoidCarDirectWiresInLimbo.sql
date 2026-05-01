CREATE procedure [dbo].[VoidCarDirectWiresInLimbo]
as
  set nocount on;

	declare @D datetime, @WireId int
	DECLARE @CardChargeId int
    DECLARE @Action varchar(100)
	DECLARE @VoidOK BIT=0

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


	    SELECT TOP 1 @CardChargeId = r.ResultId
	      FROM Card_CenPosResults as r
			   INNER JOIN WiresTAG as t on r.WireTAG = t.WireTAG
	     WHERE t.Wireid = @WireId
		   AND r.ResponseResult = 0
		 ORDER BY r.ResultId desc
	    IF @@ROWCOUNT = 0
		   BEGIN
		     exec [dbo].[CardDirect_VoidWire_Result] @WireId ,@VoidOK OUTPUT
			 SET @Action = 'CardDirect_VoidWire'
		   END 
		ELSE BEGIN
		       EXEC CardDirectChargeOk_ @WireId , @CardChargeId , 2 --CenPos
			   SET @Action = 'CardDirectChargeOk_'
		     END


        INSERT INTO CardDirectProcessLog (WireId,SPName ,Created ,ActionDescription ,SenderPaymentMethodID ,CardChargeId)
                                  VALUES (@WireId,'VoidCarDirectWiresInLimbo',getdate(),@Action, 5,@CardChargeId )



	end

	close curCardirectLostWires;
	Deallocate curCardirectLostWires;
