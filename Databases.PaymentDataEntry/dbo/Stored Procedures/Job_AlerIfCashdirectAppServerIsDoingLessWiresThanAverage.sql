CREATE procedure [dbo].[Job_AlerIfCashdirectAppServerIsDoingLessWiresThanAverage]
as
  set nocount on;
  
declare @D datetime, @Last30Min datetime, @AvgWires float, @MsgId int, @H int
declare @AppSrvIP varchar(50), @TWires int, @DiffVsAvg int, @Msg varchar(max)

declare @CDAppServerActivity table(SampleTime datetime, AppSrvIP varchar(50), TWires int, DiffVsAvg float)

select @D = dbo.DateOnly(GetDate()),
       @Last30Min = DATEADD(minute, -30, GetDate())

insert into @CDAppServerActivity(SampleTime, AppSrvIP, TWires)
	select GETDATE(), DoneFromIP, COUNT(*) as TWires
	from dbo.Wires
	where SourceApp = 6 and WireDatetime >= @Last30Min
	group by DoneFromIP 
    order by DoneFromIP

select @AvgWires = IsNull(AVG(TWires), 1)
from @CDAppServerActivity

if @AvgWires < 1
  Set @AvgWires = 1  --to avoid error in Div bellow

update @CDAppServerActivity set DiffVsAvg = ((TWires - @AvgWires) * 100.00) / @AvgWires

 declare curBadAppSrv cursor for
	select T1.IPAddress, IsNull(TWires, 0), IsNull(DiffVsAvg, -100)
	from CashdirectAppServers T1
	   left outer join @CDAppServerActivity T2 on T1.IPAddress = T2.AppSrvIP
	where T1.InProd = 1 and IsNull(DiffVsAvg, -100) < -30

 select @Msg = '', @H = DATEPART(hour, GetDate())

 if @H >= 8 and @H <= 22
 begin
	 open curBadAppSrv

	 while 1=1
	 begin
	   FETCH NEXT FROM curBadAppSrv INTO @AppSrvIP, @TWires, @DiffVsAvg
	   if @@FETCH_STATUS <> 0
		 Break;
	    
	   Set @Msg = @Msg + 'Server Ip: ' + ISNULL(@AppSrvIP, '') + ' is doing ' + CAST(IsNull(@TWires, 0) as varchar) + 
						' wires in the last 30 min. Which is ' + CAST(isNull(@DiffVsAvg, 0) as varchar(4)) + ' percentage less than average wires done. </br>'
	  end

	  close curBadAppSrv
	  deallocate curBadAppSrv
	  
	  if @Msg <> ''
		begin
		  Set @Msg = '<html><body>' + @Msg + '</body></html>'
		  --Send email
	      
		  EXEC WireSearch.[dbo].[SendEmail]
				@SenderEmail = 'aibarra@example.com',
				@SenderName = 'System Alert',
				@Email = 'aibarra@example.com',
				@Subject = 'Possible Cashdirect App Server Down.',
				@MsgBody = @Msg,
				@Tag = '1',
				@MsgId = @MsgId OUTPUT
		end
  end
  
  insert into [192.168.1.135].ProcMonitoring.dbo.CDAppServerWires(SampleTime, AppSrvIP, TWires)
    select SampleTime, AppSrvIP, TWires
    from @CDAppServerActivity