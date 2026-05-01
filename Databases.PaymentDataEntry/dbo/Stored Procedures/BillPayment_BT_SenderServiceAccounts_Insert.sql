
CREATE PROCEDURE BillPayment_BT_SenderServiceAccounts_Insert
	@BTSenderId int,
	@BTAgPayerCode varchar(10),
	@BTBillerId varchar(20),
	@BTBillerGroupId int,
	@BTBillerAddressId bigint,
	@BTBillerAddress varchar(200),
	@BTAccountNumber varchar(20),
	@BTPayeeId bigint,
	@CreatedBy varchar(15)
AS
BEGIN

	INSERT INTO SqlMain.WireTransac.dbo.BT_SenderServiceAccounts (BTSenderId, BTAgPayerCode, BTBillerId, BTBillerGroupId, BTAccountNumber, BTPayeeId, BTBillerAddressId, BTBillerAddress, CreatedBy, UpdatedBy)
								  VALUES (@BTSenderId, @BTAgPayerCode, @BTBillerId, @BTBillerGroupId, @BTAccountNumber, @BTPayeeId, @BTBillerAddressId, @BTBillerAddress, @CreatedBy, @CreatedBy)

END
