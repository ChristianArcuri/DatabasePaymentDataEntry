CREATE procedure CFPB_CalculateWireAvailableDate_DE
@WireDatetime datetime,
@AgPayerCode varchar(10),
@BranchId int,
@NoFaxBackWire bit,
@TranTypeId int,
@SourceApp int,
@WireReplacementType int,
@WireAvailableDate datetime output
as
  set nocount on;
  
  Set @WireAvailableDate = DATEADD(hour, 1, Getdate())
  
  