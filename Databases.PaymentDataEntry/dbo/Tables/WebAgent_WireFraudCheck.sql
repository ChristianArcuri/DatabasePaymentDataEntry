CREATE TABLE [dbo].[WebAgent_WireFraudCheck] (
    [WireId]                   INT          NOT NULL,
    [FraudCheckTransacId]      VARCHAR (50) NULL,
    [FraudCheckDecision]       VARCHAR (10) NULL,
    [FraudCheckDecisionReason] VARCHAR (10) NULL,
    [FraudCheckScore]          INT          NULL,
    [FraudCheckDate]           DATETIME     NULL,
    CONSTRAINT [PK_WebAgent_WireFraudCheck] PRIMARY KEY CLUSTERED ([WireId] ASC)
);

