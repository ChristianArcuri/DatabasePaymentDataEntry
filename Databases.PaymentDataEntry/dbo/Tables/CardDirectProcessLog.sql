CREATE TABLE [dbo].[CardDirectProcessLog] (
    [RecordId]              INT           IDENTITY (1, 1) NOT NULL,
    [WireId]                INT           NULL,
    [SPName]                VARCHAR (100) NULL,
    [Created]               DATETIME      NULL,
    [ActionDescription]     VARCHAR (100) NULL,
    [SenderPaymentMethodID] INT           NULL,
    [CardChargeId]          INT           NULL,
    PRIMARY KEY CLUSTERED ([RecordId] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_CardDirectProcessLog_WireId]
    ON [dbo].[CardDirectProcessLog]([WireId] ASC) WITH (FILLFACTOR = 90);

