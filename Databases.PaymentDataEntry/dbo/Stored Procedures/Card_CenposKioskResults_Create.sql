
CREATE PROCEDURE [dbo].[Card_CenposKioskResults_Create]
	@WireTAG varchar(20),
    @JsonRequest varchar(max),
    @JsonResponse varchar(max),
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