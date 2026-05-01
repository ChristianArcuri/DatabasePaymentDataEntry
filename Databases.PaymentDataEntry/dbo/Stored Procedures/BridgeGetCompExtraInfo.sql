CREATE procedure BridgeGetCompExtraInfo (@WireId int, 
                                         @StsComplianceOk bit,
                                         @ExclStatement bit output,
                                         @CompReleaseDate datetime output,
                                         @CompReleaseBy varchar(15) output)
as
    set nocount on;
  
	SET @ExclStatement = 0
	IF @StsComplianceOk = 0 --The wire is on hold by compliance
	 BEGIN
	   SET @CompReleaseDate = NULL
	   SET @CompReleaseBy    = ''
	   IF  NOT EXISTS (Select * 
						 from WireCompliance.dbo.Comp_WireOnHold as h
							  inner join WireCompliance.dbo.Comp_OnHoldReasons as R on (h.OnHoldReasonId = R.OnHoldReasonId)      
						where h.WireId = @WireId
						  and h.Status ='P'
						  and R.ExclStatement = 0)
		   SET @ExclStatement = 1
	 END
	ELSE 
	 BEGIN
	   IF EXISTS(Select * 
	             from WireCompliance.dbo.Comp_WireOnHold
				 where WireId = @WireId and Status ='A')
         select @CompReleaseDate = getdate(), 
		        @CompReleaseBy    = 'SYSTEM'
	   ELSE 
		 select @CompReleaseDate = NULL, 
		        @CompReleaseBy    = ''
	  END
