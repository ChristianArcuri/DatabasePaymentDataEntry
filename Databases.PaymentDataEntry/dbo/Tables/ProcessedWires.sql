CREATE TABLE [dbo].[ProcessedWires] (
    [WireID]  INT      NOT NULL,
    [Done]    SMALLINT CONSTRAINT [DF_ProcessedWires_Done] DEFAULT ((0)) NOT NULL,
    [Control] INT      NULL,
    [WireChk] BIT      CONSTRAINT [DF_ProcessedWires_WireChk] DEFAULT ((0)) NOT NULL,
    [Sync_DE] BIT      CONSTRAINT [DF_ProcessedWires_Sync_DE] DEFAULT ((0)) NULL,
    [created] DATETIME DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ProcessedWires] PRIMARY KEY CLUSTERED ([WireID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_ProcessedWires_DoneWireID]
    ON [dbo].[ProcessedWires]([Done] ASC, [WireID] ASC) WITH (FILLFACTOR = 80);

