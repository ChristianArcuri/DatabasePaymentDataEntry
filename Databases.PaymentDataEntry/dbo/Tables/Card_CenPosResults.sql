CREATE TABLE [dbo].[Card_CenPosResults] (
    [ResultId]         INT             IDENTITY (1, 1) NOT NULL,
    [WireTAG]          VARCHAR (20)    NOT NULL,
    [AuthCode]         VARCHAR (20)    NULL,
    [Amount]           DECIMAL (18, 2) NULL,
    [Donation]         DECIMAL (18, 2) NULL,
    [OriginalAmount]   DECIMAL (18, 2) NULL,
    [CardType]         VARCHAR (50)    NULL,
    [CardNumber]       VARCHAR (30)    NULL,
    [IsCommercialCard] BIT             NULL,
    [NameOnCard]       VARCHAR (100)   NULL,
    [Email]            VARCHAR (100)   NULL,
    [EntryMethod]      VARCHAR (30)    NULL,
    [ReferenceNumber]  BIGINT          NULL,
    [TraceNumber]      VARCHAR (50)    NULL,
    [ResponseResult]   VARCHAR (10)    NULL,
    [ResponseMessage]  VARCHAR (2000)  NULL,
    [ProcessAs]        VARCHAR (30)    NULL,
    [SessionId]        VARCHAR (50)    NULL,
    [Token]            VARCHAR (50)    NULL,
    [Operation]        VARCHAR (30)    NULL,
    [Signature]        VARCHAR (30)    NULL,
    [Created]          DATETIME        CONSTRAINT [DF_Card_CenPosResults_Created] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Card_CenPosResults] PRIMARY KEY CLUSTERED ([ResultId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Card_CenPosResults_WireTag]
    ON [dbo].[Card_CenPosResults]([WireTAG] ASC);

