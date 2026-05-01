CREATE TABLE [dbo].[SyncErrorLog] (
    [ErrLogID] INT           IDENTITY (1, 1) NOT NULL,
    [Process]  VARCHAR (50)  NOT NULL,
    [ErrMsg]   VARCHAR (MAX) NULL,
    [Created]  DATETIME      CONSTRAINT [DF_SyncErrorLog_Created] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_SyncErrorLog] PRIMARY KEY CLUSTERED ([ErrLogID] ASC) WITH (FILLFACTOR = 80)
);

