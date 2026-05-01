CREATE TABLE [dbo].[ImxDirect_PerformanceLog] (
    [Sp]            VARCHAR (100)    NULL,
    [PreparationId] UNIQUEIDENTIFIER NULL,
    [AgSenderCode]  VARCHAR (10)     NULL,
    [Step]          INT              NULL,
    [StepTime]      DATETIME         NULL
);

