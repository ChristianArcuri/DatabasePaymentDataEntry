CREATE PROCEDURE [dbo].[CRM_MakeWire_LoyaltyPointsManager_OldJun11_2019]
@AgSenderCode varchar(10),
@AgSenderSeq int,
@SameSenderId int,
@TranTypeID int,
@PointsTranType varchar(10),
@PointsToRedeem int,
@PointsRedemptionId int,
@PointsAdded int OUTPUT

AS
BEGIN
  set nocount on;

  DECLARE @ExpDays	INT
  DECLARE @Today date
  DECLARE @ErrorCode      varchar(10)

  SET @Today  = dbo.DateOnly(getdate())

  
  IF @PointsTranType = 'WIRE'
     BEGIN
	   SELECT @PointsAdded  = Points         
	     FROM WirePricing.dbo.CRM_LoyaltyPointsSetUp
		WHERE TranTypeId = @TranTypeID
 		
	 END
  ELSE -- Redemption
     BEGIN
	 EXEC  SqlMain.WireTransac.dbo.CRM_PointRedemption @SameSenderId   = @SameSenderId,
                                                       @PointsToRedeem = @PointsToRedeem,
				                                       @Sign           = -1,
                                                       @PointsTranType = 'REDEEM',
                                                       @AgSenderCode   = @AgSenderCode,
                                                       @AgSenderSeq    = @AgSenderSeq ,
                                                       @Control        = 0,
                                                       @SenderId       = 0,
													   @PointsRedemptionId = @PointsRedemptionId,
                                                       @ErrorCode      = @ErrorCode  OUTPUT

	 END


END