CREATE TABLE [dbo].[WiresTAGCompChecked] (
    [ID]      INT       IDENTITY (1, 1) NOT NULL,
    [WireTAG] CHAR (15) NOT NULL,
    [Created] DATETIME  CONSTRAINT [DF_WiresTAGCompChecked_Created] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_WiresTAGCompChecked] PRIMARY KEY CLUSTERED ([ID] ASC)
);

