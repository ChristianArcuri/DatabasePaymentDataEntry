CREATE TABLE [dbo].[WiresTAG] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [WireTAG]      CHAR (15)      NOT NULL,
    [WireID]       INT            NOT NULL,
    [PswHash]      VARBINARY (32) NULL,
    [AppHash]      VARBINARY (32) NULL,
    [AgComputerid] INT            NULL,
    [Created]      DATETIME       CONSTRAINT [DF_WiresTAG_Created] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WiresTAG] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_WiresTAG_WireTag]
    ON [dbo].[WiresTAG]([WireTAG] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [FD_IX_WiresTag_WireID]
    ON [dbo].[WiresTAG]([WireID] ASC)
    INCLUDE([WireTAG]) WITH (FILLFACTOR = 90);

