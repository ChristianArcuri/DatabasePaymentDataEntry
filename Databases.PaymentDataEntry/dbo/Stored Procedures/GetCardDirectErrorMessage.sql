

CREATE PROCEDURE GetCardDirectErrorMessage @MsgBody varchar(max) output 
as
  set nocount on;

--declare @MsgBody varchar(max)
declare @CardChargeId int, @Wireid int, @AgencyCode varchar(20), @AgSenderSeq int, @ErrorMsg varchar(max)
declare @CR char(2), @RowCount int = 0 

SET @CR = CHAR(13)+CHAR(10);

SET @MsgBody =  
               '<html><body>' + + @CR + 
               '<table width="871" border="0" cellspacing="0" cellpadding="0"> '+ @CR + '<tr>' +
               '<td width="92"><strong>Wire</strong></td> ' + @CR +
               '<td width="79"><strong>Agency</strong></td> ' + @CR +
               '<td width="72"><strong>Ag. Seq.</strong></td> ' + @CR +
               '<td width="618"><strong>Error</strong></td> ' + @CR + '</tr>' + @CR

declare curCarDirectErrors cursor FAST_FORWARD for
	SELECT TOP 10 CardChargeId, WireId, AgencyCode, AgSenderSeq, ErrorMsg
	FROM CardChargeResult
	where Len(rtrim(ErrorMsg)) > 40 and AlertSent is null
	ORDER BY CardChargeId DESC;

 OPEN curCarDirectErrors

 while 1=1
 begin
   FETCH NEXT FROM curCarDirectErrors INTO @CardChargeId, @WireId, @AgencyCode, @AgSenderSeq, @ErrorMsg 
   IF @@FETCH_STATUS <> 0
     Break;

   SET @RowCount = @RowCount + 1;
   SET @MsgBody = @MsgBody + '<tr><td>' + cast(@WireId as varchar) + '</td><td>' + rtrim(@AgencyCode) + 
                             '</td><td>' + cast(@AgSenderSeq as varchar) + '</td><td>' + rtrim(@ErrorMsg) + '</td></tr>'

   update CardChargeResult set AlertSent = Getdate()
   where CardChargeId = @CardChargeId
 end

 CLOSE curCarDirectErrors;
 DEALLOCATE curCarDirectErrors;
  
 IF @RowCount > 0
   SET @MsgBody = @MsgBody + '</table></body></html>'
 ELSE
   SET @MsgBody = ''
  

--  select @MsgBody

