CREATE TABLE [dbo].[CRM_RedeemErrors] (
    [AgSendercode] VARCHAR (10)   NULL,
    [AgSenderSeq]  INT            NULL,
    [WirePoints]   INT            NULL,
    [ErrorMsg]     VARCHAR (4000) NULL,
    [D]            DATETIME       DEFAULT (getdate()) NULL
);

