CREATE view [dbo].[ViewWiresAndClientIps]
as
select p.control, 
       T3.ID, T3.IP, T3.Process, T3.Tag, T3.Created, 
	   T1.*
from dbo.Wires T1
  join dbo.WiresTAG T2 ON T1.WireId = T2.WireID
  join dbo.ProcessedWires as p on t1.wireid = p.wireid
  left outer join dbo.ConnLog T3 ON T2.WireTAG = T3.Tag
where  dbo.GetBuildNo(AppVersion) >= '454'
--order by T1.WireId desc



