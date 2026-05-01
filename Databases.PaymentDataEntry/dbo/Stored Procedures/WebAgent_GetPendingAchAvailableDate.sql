CREATE PROCEDURE [dbo].[WebAgent_GetPendingAchAvailableDate]
@AvailableDate datetime OUTPUT

as
begin
    DECLARE @time time
	DECLARE @PendingDays int
	DECLARE @d int
	
	DECLARE @StartDate datetime 

	
	set @time = convert(varchar,getdate(),108)
	if  @time < '15:50:00'
 		 SET @PendingDays = 4
	ELSE SET @PendingDays = 5

	PRINT @Pendingdays
	SET @d = 1
	
	set @StartDate = dbo.dateonly(getdate())
	WHILE @d <= @PendingDays
	  BEGIN  
	    EXEC SqlMain.WireTransac.dbo.CalculateNextWorkday 	@StartDate ,@AvailableDate OUTPUT

		SET @StartDate = @AvailableDate 
		SET @d = @d + 1
	  END
	

end