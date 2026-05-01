CREATE TABLE [dbo].[CardChargeResult] (
    [CardChargeId]       INT             IDENTITY (1, 1) NOT NULL,
    [WireId]             INT             NULL,
    [AgencyCode]         VARCHAR (20)    NOT NULL,
    [AgSenderSeq]        INT             NULL,
    [LastCardDigits]     VARCHAR (20)    NULL,
    [NameOnCard]         VARCHAR (50)    NULL,
    [ExpDate]            CHAR (4)        NULL,
    [MagStripedata]      VARCHAR (1024)  NULL,
    [PinData]            VARCHAR (50)    NULL,
    [TranAmount]         NUMERIC (18, 2) NULL,
    [PinPadSerialNumber] VARCHAR (50)    NULL,
    [MSRKeySerialNumber] VARCHAR (50)    NULL,
    [WireTAG]            VARCHAR (20)    NULL,
    [TranSuccessful]     BIT             NULL,
    [ResultCode]         VARCHAR (10)    NULL,
    [PnRef]              VARCHAR (100)   NULL,
    [AuthCode]           VARCHAR (100)   NULL,
    [ErrorMsg]           VARCHAR (MAX)   NULL,
    [ResultMessage]      VARCHAR (MAX)   NULL,
    [HostCode]           VARCHAR (100)   NULL,
    [AvsResult]          VARCHAR (10)    NULL,
    [IsCommercialCard]   BIT             NULL,
    [CardType]           VARCHAR (50)    NULL,
    [RequestData]        VARCHAR (MAX)   NULL,
    [ResponseData]       VARCHAR (MAX)   NULL,
    [Created]            DATETIME        CONSTRAINT [DF_CardChargeResult_Created] DEFAULT (getdate()) NULL,
    [CreatedDate]        AS              (CONVERT([date],[Created],(0))) PERSISTED,
    [AlertSent]          DATETIME        NULL,
    CONSTRAINT [PK_CardChargeResult] PRIMARY KEY CLUSTERED ([CardChargeId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_CardChargeResult_AgencyCode_AgSenderSeq]
    ON [dbo].[CardChargeResult]([AgencyCode] ASC, [AgSenderSeq] ASC);

