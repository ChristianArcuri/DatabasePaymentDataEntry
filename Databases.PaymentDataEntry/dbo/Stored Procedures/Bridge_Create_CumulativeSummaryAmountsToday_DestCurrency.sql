/**
    Name:           Bridge_Create_CumulativeSummaryAmountsToday_DestCurrency
    Author:         Agustin Aguilar
    Written:        6/22/2023
    Purpose:        Wraps [WireComplicance].[dbo].[spi_Create_CumulativeSummaryAmountsToday_DestCurrency]

    Edit History:   6/22/2023 - Aguilar Agustin
                        + Initial creation.
**/


CREATE PROCEDURE [dbo].[Bridge_Create_CumulativeSummaryAmountsToday_DestCurrency]
    @WireId int,
    @TotAmount money, 
	@TotDestAmount money,
	@SenderName varchar(150), 
    @OriCurrencyCode char(3), 
	@SndCountry varchar(30), 
    @SndState varchar(30), 
    @SndCity varchar(30),
	@ReceiverName varchar(150), 
    @DestCurrencyCode char(3), 
	@PyrCountry varchar(30), 
    @PyrState varchar(30), 
    @PyrCity varchar(30),
	@SndPhone varchar(20), 
    @RcvPhone varchar(20),
	@TransfDeptBank varchar(60), 
    @TransfAccount varchar(30),
	@AgPayerCode varchar(20)

AS
BEGIN
    exec WireCompliance.dbo.spi_Create_CumulativeSummaryAmountsToday_DestCurrency  
        @WireId, @TotAmount,	@TotDestAmount,	@SenderName, @OriCurrencyCode, 
        @SndCountry, @SndState, @SndCity, @ReceiverName, @DestCurrencyCode, 
        @PyrCountry, @PyrState, @PyrCity, @SndPhone, @RcvPhone,
        @TransfDeptBank, @TransfAccount,	@AgPayerCode
END
GO