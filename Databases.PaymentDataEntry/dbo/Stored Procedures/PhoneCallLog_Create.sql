CREATE PROCEDURE [dbo].[PhoneCallLog_Create]
@WireAgencyCode   varchar(10),
@WireAgencyId     int,
@WireAgStateAbbr  char(3),
@WireAgCountryAbbr char(3),
@SysAgencyCode    varchar(10),
@UserName         varchar(10),
@CallerId         varchar(20),
@Extension        int,
@ComputerName     varchar(30),
@AgSenderSeq      int
AS
BEGIN

	EXEC sqlMain.WireTransac.dbo.PhoneCallLog_Create @WireAgencyCode,
	@WireAgencyId,
	@WireAgStateAbbr,
	@WireAgCountryAbbr,
	@SysAgencyCode,
	@UserName,
	@CallerId,
	@Extension,
	@ComputerName,
	@AgSenderSeq 

END