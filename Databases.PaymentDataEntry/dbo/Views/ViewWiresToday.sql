create view ViewWiresToday
as
select *
from Wires with(nolock)
where WireDate = dbo.DateOnly(GetDate())