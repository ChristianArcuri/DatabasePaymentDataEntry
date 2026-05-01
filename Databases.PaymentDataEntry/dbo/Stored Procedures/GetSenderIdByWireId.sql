
CREATE PROCEDURE GetSenderIdByWireId
	@WireId int,
	@SenderId int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

    
	SELECT @SenderId = LSenderId
	FROM Wires with(nolock)
	WHERE WireId = @WireId

	IF @SenderId IS NULL
		SET @SenderId = 0
END
