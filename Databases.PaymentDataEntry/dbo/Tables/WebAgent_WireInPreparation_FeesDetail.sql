CREATE TABLE [dbo].[WebAgent_WireInPreparation_FeesDetail] (
    [RecordId]                 INT              IDENTITY (1, 1) NOT NULL,
    [StyleId]                  INT              NOT NULL,
    [PreparationId]            UNIQUEIDENTIFIER NOT NULL,
    [SenderPaymentMethodId]    INT              NOT NULL,
    [SenderPaymentMethodName]  VARCHAR (40)     NULL,
    [IsAvailable]              BIT              DEFAULT ((1)) NOT NULL,
    [SenderPaymentMethodOrder] INT              NULL,
    [FeeAmount]                MONEY            NULL,
    [WebFeeId]                 INT              NULL,
    CONSTRAINT [PK_WebAgent_WireInPreparation_FeesDetail] PRIMARY KEY CLUSTERED ([RecordId] ASC)
);

