  --exec InsWireInfoInWireSearch
CREATE PROCEDURE [dbo].[InsWireInfoInWireSearch]
AS
BEGIN
	SET NOCOUNT ON;
    declare
       @ErrMsg varchar(50),
       @Process varchar(50), @WireId int,
       @SenderId int, @DataEntrySenderId int,
       @SndFullName varchar(150), @SndFirstName varchar(50), @SndLast1 varchar(50), @SndLast2 varchar(50), 
       @SndAddress varchar(50), @SndCountry varchar(30), @SndState varchar(30),
	   @SndCity varchar(40), @SndZip varchar(15), @SndPhone varchar(20),
	   @NoSecondLastName bit, @SenderGroupId int,
       @ReceiverId int, @DataEntryReceiverId int,
       @RcvFullName varchar(150), @RcvFirstName varchar(50), @RcvLast1 varchar(50),
	   @RcvLast2 varchar(50), @RcvAddress varchar(200), @RcvCountry varchar(30), @RcvState varchar(30),
	   @RcvCity varchar(40), @RcvZip varchar(15), @RcvPhone varchar(20),
       @TranTypeId int, @PayerId int, 
       @PayerCode varchar(10), @BranchId int, @DeliveryMethod char(1), @OriCurrency char(3), 
       @DestCurrency char(3), @AccountNumber varchar(20), @DeptBankName varchar(60), 
       @AccountType smallint, @BankBranchCode varchar(7), @DepAdditionalInfo varchar(60), @RateTypeId int,
       @WireDatetime datetime, @AgSenderId int, @AgSenderCode varchar(20),
       @PayerPayMethodId int
	   
    
    declare curWires cursor for
		select top 1000 T1.WireId,
		       T3.SenderId, T3.LSenderId, T3.SndFullName, SndFirstName, SndLast1, SndLast2, SndAddress, SndCountry, 
		       SndState, SndCity, SndZip, SndPhone, SndNoSecLastName, SenderGroupId,
			   T4.ReceiverId, T4.LReceiverId, RcvFullName, RcvFirstName, RcvLast1, RcvLast2, RcvAddress, RcvCountry, 
			   RcvState,RcvCity, RcvZip, RcvPhone,
			   TranTypeID, AgPayerId, AgPayerCode, BranchId, DeliveryType, OriCurrency, DestCurrency, AccountNumber,
			   DeptBankName, AccountType, BankBranchCode, DeptAdditionalInfo, RateTypeID, WireDatetime, 
			   AgSenderId, AgSenderCode 
		from ProcessedWires T1 with(nolock)
		  JOIN Wires T2 with(nolock) ON T1.WireID = T2.WireId
		  JOIN Senders T3 with(nolock) ON T3.LSenderId = T2.LSenderId
		  JOIN Receivers T4 with(nolock) ON T4.LReceiverId = T2.LReceiverId
		where Sync_DE = 0
		
  
  BEGIN TRY  
		
    open curWires
    while 1=1
    begin
      FETCH NEXT FROM curWires INTO 
       @WireId,
       @SenderId, @DataEntrySenderId, @SndFullName, @SndFirstName, @SndLast1, @SndLast2, @SndAddress, @SndCountry, 
       @SndState, @SndCity, @SndZip, @SndPhone, @NoSecondLastName, @SenderGroupId,
       @ReceiverId, @DataEntryReceiverId,
       @RcvFullName, @RcvFirstName, @RcvLast1, @RcvLast2, @RcvAddress, @RcvCountry, 
       @RcvState, @RcvCity, @RcvZip, @RcvPhone,
       @TranTypeId, @PayerId, @PayerCode, @BranchId, @DeliveryMethod, @OriCurrency, @DestCurrency, @AccountNumber, 
       @DeptBankName, @AccountType, @BankBranchCode, @DepAdditionalInfo, @RateTypeId, @WireDatetime, 
       @AgSenderId, @AgSenderCode  	   
       
      if @@FETCH_STATUS <> 0 
        break

      if @RateTypeId = 0
        SET @RateTypeId = 1
      
      if @TranTypeId = 4
        Set @PayerPayMethodId = 3
      else 
        Set @PayerPayMethodId = 1

     begin try
       exec WireSearch.dbo.SyncFromDataEntry
		   @SenderId, @DataEntrySenderId,
		   @SndFullName, @SndFirstName, @SndLast1, @SndLast2, 
		   @SndAddress, @SndCountry, @SndState,
		   @SndCity, @SndZip, @SndPhone,
		   @NoSecondLastName, @SenderGroupId,
		   @ReceiverId, @DataEntryReceiverId,
		   @RcvFullName, @RcvFirstName, @RcvLast1,
		   @RcvLast2, @RcvAddress, @RcvCountry, @RcvState,
		   @RcvCity, @RcvZip, @RcvPhone,
		   @TranTypeId, @PayerId, 
		   @PayerCode, @BranchId, @DeliveryMethod, @PayerPayMethodId, @OriCurrency,
		   @DestCurrency, @AccountNumber, @DeptBankName, 
		   @AccountType, @BankBranchCode, @DepAdditionalInfo, @RateTypeId,
		   @WireDatetime, @AgSenderId, @AgSenderCode

	   update ProcessedWires with(updlock) Set Sync_DE = 1
	   where WireID = @WireId	   
	end try
	begin catch
	  Set @Process = 'SYNC DE-' + CAST(@WireId as varchar)
      exec spi_Error_LOG @Process
	
--	   insert into TEST(Msg, NUM) values ('Error', @WireId)
--	   print cast(@WireId as varchar)
	end catch
		   
    end
    
    close curWires
    deallocate curWires		

  END TRY
  BEGIN CATCH
    Set @ErrMsg = 'From DE to Searching SP ' + @ErrMsg
    EXEC dbo.spi_Sync_Error_LOG @ErrMsg
  END CATCH      
    
END
