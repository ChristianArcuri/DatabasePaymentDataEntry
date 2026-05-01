CREATE TABLE [dbo].[AppTokenErrors] (
    [ID]       INT      IDENTITY (1, 1) NOT NULL,
    [WireID]   INT      NOT NULL,
    [Notified] DATETIME NULL,
    [Created]  DATETIME CONSTRAINT [DF_AppTokenErrors_Created] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_AppTokenErrors] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_AppTokenErrors_WireId]
    ON [dbo].[AppTokenErrors]([WireID] ASC);

