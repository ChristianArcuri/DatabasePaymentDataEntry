
CREATE PROCEDURE [dbo].[ImxDirect_WIRE_CheckMonerisTransaction]
	@AgencyCode varchar(10),
	@AuthCode varchar(20),
	@IsApproved bit OUTPUT
AS
BEGIN
	DECLARE	 @AgLike varchar(20)
			,@Date datetime

	SET @AgLike = @AgencyCode + '%'
	SET @Date = dbo.DateOnly(GETDATE())
	SET @IsApproved = 0

	IF NOT EXISTS (
			SELECT AuthCode
			  FROM Card_CenPosResults
			 WHERE Created >= @Date
			   AND WireTAG LIKE @AgLike
			   AND AuthCode = @AuthCode
			   AND ResponseResult = '001')
	BEGIN
		SET @IsApproved = 1
	END
END