
CREATE PROCEDURE FaxWireReceipt @AgencyCode varchar(20), @AgSenderSeq int
AS
BEGIN
	SET NOCOUNT ON;

    declare @WireId int
    
    select @WireId = WireId 
    from Wires with(nolock)
    where AgSenderCode = @AgencyCode and AgSenderSeq = @AgSenderSeq
    
    if rtrim(@AgencyCode) = 'FL1000'
    insert into WiresToFax(WireId, Fax1025) values (@WireId, 0)

END
