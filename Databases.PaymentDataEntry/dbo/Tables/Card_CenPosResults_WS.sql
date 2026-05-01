CREATE TABLE [dbo].[Card_CenPosResults_WS] (
    [ResultID]             INT             IDENTITY (1, 1) NOT NULL,
    [IsSuccessful]         BIT             NULL,
    [InfoMessage]          VARCHAR (MAX)   NULL,
    [ResultCode]           INT             NULL,
    [ResultMessage]        VARCHAR (MAX)   NULL,
    [MerchantId]           INT             NULL,
    [Username]             VARCHAR (50)    NULL,
    [Created]              DATETIME        NULL,
    [TranType]             VARCHAR (20)    NULL,
    [PaymentType]          VARCHAR (20)    NULL,
    [CardNumber]           VARCHAR (16)    NULL,
    [TotalAmount]          DECIMAL (18, 2) NULL,
    [AuthAmount]           DECIMAL (18, 2) NULL,
    [InvoiceNumber]        VARCHAR (50)    NULL,
    [ResponseResult]       INT             NULL,
    [ResponseMessage]      VARCHAR (MAX)   NULL,
    [ReferenceNumber]      BIGINT          NULL,
    [AuthCode]             VARCHAR (20)    NULL,
    [IsSettled]            BIT             NULL,
    [SettleDate]           DATETIME        NULL,
    [NameOnCard]           VARCHAR (100)   NULL,
    [CardType]             VARCHAR (50)    NULL,
    [EntryMethod]          VARCHAR (30)    NULL,
    [CardExpirationDate]   VARCHAR (10)    NULL,
    [OriginalAmount]       DECIMAL (18, 2) NULL,
    [CardHostMerchantId]   VARCHAR (20)    NULL,
    [CardHostMerchantName] VARCHAR (100)   NULL,
    [HostName]             VARCHAR (100)   NULL,
    [CustomerCode]         VARCHAR (50)    NULL,
    [EntryMode]            VARCHAR (20)    NULL,
    [TaxAmount]            DECIMAL (18, 2) NULL,
    [RecInserted]          DATETIME        CONSTRAINT [DF_Card_CenPosResults_WS_RecInserted] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Card_CenPosResults_WS] PRIMARY KEY CLUSTERED ([ResultID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Card_CenPosResults_WS_InvoiceNumber]
    ON [dbo].[Card_CenPosResults_WS]([InvoiceNumber] ASC);

