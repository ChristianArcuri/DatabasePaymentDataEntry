CREATE TABLE [dbo].[LogFxRateIdEmpty] (
    [ID]          INT          IDENTITY (1, 1) NOT NULL,
    [AgencyCode]  VARCHAR (20) NOT NULL,
    [AgSenderSeq] INT          NOT NULL,
    [WireId]      INT          NOT NULL,
    [Created]     DATETIME     CONSTRAINT [DF_LogFxRateIdEmpty_Created] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_LogFxRateIdEmpty] PRIMARY KEY CLUSTERED ([ID] ASC)
);

