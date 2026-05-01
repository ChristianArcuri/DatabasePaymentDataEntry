create procedure AvgWiresPerSec
as
  set nocount on;
  
declare @Last5Min datetime = Dateadd(minute, -2, GetDate())

;with AvgWireSec 
as
(
	select DATEPART(MINUTE, WireDatetime) as m, DATEPART(second, WireDatetime) as s, COUNT(*) as TWires
	from Wires with(nolock)
	where WireDatetime >= @Last5Min
	group by DATEPART(MINUTE, WireDatetime), DATEPART(second, WireDatetime)
)

select ((SUM(TWires) * 1.0)/ COUNT(*)) as AvgWirePerSec
from AvgWireSec
--order by m,s
