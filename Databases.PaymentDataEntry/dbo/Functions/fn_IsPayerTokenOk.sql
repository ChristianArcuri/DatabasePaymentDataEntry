create FUNCTION [dbo].[fn_IsPayerTokenOk] (@WireId int)
RETURNS bit
AS
BEGIN
   DECLARE @R bit

   if Exists(select *
	         from Wires T1 with(nolock)
	         where SourceApp = 6 and WireId = @WireId and
		           dbo.IsReplWire(AppVersion) = 0 and 
		           dbo.GetBuildNo(AppVersion) >= '452' and
		           dbo.IsAppSignValid(AppVersion, PayerSecToken) = 0 and
		          not Exists(select * from AppTokenErrors T01 where T01.WireId = T1.WireId))
	  Set @R = 0
   else
      Set @R  = 1	  	  
		  
  Return @R;
END