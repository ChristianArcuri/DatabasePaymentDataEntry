CREATE TABLE [dbo].[ConnLog] (
    [ID]      INT          IDENTITY (1, 1) NOT NULL,
    [IP]      VARCHAR (50) NOT NULL,
    [Process] INT          NULL,
    [Tag]     VARCHAR (50) NULL,
    [Created] DATETIME     CONSTRAINT [DF_ConnLog_Created] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ConnLog] PRIMARY KEY CLUSTERED ([ID] ASC)
);

