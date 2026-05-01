CREATE TABLE [dbo].[ImxDirect_SignedDataErrorLog] (
    [RecordId]     INT             IDENTITY (1, 1) NOT NULL,
    [AgSenderCode] VARCHAR (10)    NULL,
    [DT]           DATETIME        NULL,
    [SignedData]   VARCHAR (MAX)   NULL,
    [Signature]    VARBINARY (MAX) NULL,
    PRIMARY KEY CLUSTERED ([RecordId] ASC) WITH (FILLFACTOR = 90)
);

