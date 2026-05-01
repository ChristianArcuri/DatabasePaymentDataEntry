
CREATE view [dbo].[ViewLast15DayFraude]
as
select *
from Wires
where WireDate >= dbo.DateOnly(DateAdd(DAY, -15, GetDate())) and
     AgSenderCode <> 'FL1000' and
     WireId in (
		select WireId
		from dbo.WirePossibleFraud
		where Ok = 0
)

