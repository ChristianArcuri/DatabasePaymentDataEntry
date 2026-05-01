
CREATE PROCEDURE [dbo].[Card_CenposKioskResults_Create_OldJun24_2020]
	@WireTAG varchar(20),
    @JsonRequest varchar(1000),
    @JsonResponse varchar(1000),
    @ErrorMessage varchar(max),
    @Created datetime,
	@ResultId int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SET @ResultId = 0

	IF ISNULL(@WireTAG, '') = ''
		RETURN

    INSERT INTO Card_CenposKioskResults
           (WireTAG
           ,JsonRequest
           ,JsonResponse
           ,ErrorMessage
           ,Created)
     VALUES
           (@WireTAG
           ,@JsonRequest
           ,@JsonResponse
           ,@ErrorMessage
           ,@Created)

     SET @ResultId = SCOPE_IDENTITY()
END