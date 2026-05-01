CREATE TABLE [dbo].[ErrorLogCD] (
    [ID]      INT           IDENTITY (1, 1) NOT NULL,
    [ErrMsg]  VARCHAR (MAX) NULL,
    [Created] DATETIME      CONSTRAINT [DF_ErrorLogCD_Created] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ErrorLogCD] PRIMARY KEY CLUSTERED ([ID] ASC)
);

