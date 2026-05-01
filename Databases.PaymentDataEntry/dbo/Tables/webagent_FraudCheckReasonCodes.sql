CREATE TABLE [dbo].[webagent_FraudCheckReasonCodes] (
    [RecordId]          INT           IDENTITY (1, 1) NOT NULL,
    [ReasonCode]        INT           NULL,
    [ReasonDesc]        VARCHAR (500) NULL,
    [UserShowErrorCode] VARCHAR (10)  NULL,
    [ActionResult]      INT           NULL,
    PRIMARY KEY CLUSTERED ([RecordId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_webagent_FraudCheckReasonCodes]
    ON [dbo].[webagent_FraudCheckReasonCodes]([ReasonCode] ASC);

