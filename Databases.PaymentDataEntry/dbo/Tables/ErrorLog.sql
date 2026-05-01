CREATE TABLE [dbo].[ErrorLog] (
    [ErrLogID]    INT           IDENTITY (1, 1) NOT NULL,
    [ProcessName] VARCHAR (30)  NOT NULL,
    [ErrorMsg]    VARCHAR (MAX) NULL,
    [Created]     DATETIME      CONSTRAINT [DF_Table_1_Create] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED ([ErrLogID] ASC)
);

