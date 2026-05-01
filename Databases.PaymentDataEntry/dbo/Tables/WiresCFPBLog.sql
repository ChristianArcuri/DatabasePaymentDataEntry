CREATE TABLE [dbo].[WiresCFPBLog] (
    [CFPBLogId]               INT           IDENTITY (1, 1) NOT NULL,
    [WireTAG]                 CHAR (15)     NULL,
    [SenderId]                INT           NULL,
    [ReceiverId]              INT           NULL,
    [WireDatetime]            DATETIME      NULL,
    [AmountToBeTransferred]   MONEY         NULL,
    [FrontEndFee]             MONEY         NULL,
    [Taxes]                   MONEY         NULL,
    [ExchangeRate]            MONEY         NULL,
    [BackEndFeeTaxes]         MONEY         NULL,
    [TotalAmountToBeReceived] MONEY         NULL,
    [AgPayerCode]             CHAR (10)     NULL,
    [AgSenderCode]            CHAR (10)     NULL,
    [BranchId]                INT           NULL,
    [AgentName]               VARCHAR (50)  NULL,
    [SenderName]              VARCHAR (150) NULL,
    [AgSenderSeq]             INT           NULL,
    [Action]                  CHAR (10)     NULL,
    [UserName]                VARCHAR (15)  NULL,
    [Created]                 DATETIME      CONSTRAINT [DF_WiresCFPBLog_Created] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_WiresDeclineTerms] PRIMARY KEY CLUSTERED ([CFPBLogId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_WiresCFPBLog_WireTag]
    ON [dbo].[WiresCFPBLog]([WireTAG] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Wires.[OriAmount]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WiresCFPBLog', @level2type = N'COLUMN', @level2name = N'AmountToBeTransferred';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Wires.[Charges] + Wires.[OtherChg]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WiresCFPBLog', @level2type = N'COLUMN', @level2name = N'FrontEndFee';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Wires.[OriToDestExRate]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WiresCFPBLog', @level2type = N'COLUMN', @level2name = N'ExchangeRate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WiresCFPBLog', @level2type = N'COLUMN', @level2name = N'BackEndFeeTaxes';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Wires.[DestAmount]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WiresCFPBLog', @level2type = N'COLUMN', @level2name = N'TotalAmountToBeReceived';

