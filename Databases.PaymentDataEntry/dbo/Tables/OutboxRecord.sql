CREATE TABLE [dbo].[OutboxRecord] (
    [Id]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [MessageId]           NVARCHAR (255) NOT NULL,
    [Dispatched]          BIT            DEFAULT ((0)) NOT NULL,
    [DispatchedAt]        DATETIME       NULL,
    [TransportOperations] NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    UNIQUE NONCLUSTERED ([MessageId] ASC),
    UNIQUE NONCLUSTERED ([MessageId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [OutboxRecord_Dispatched_Idx]
    ON [dbo].[OutboxRecord]([Dispatched] ASC);


GO
CREATE NONCLUSTERED INDEX [OutboxRecord_DispatchedAt_Idx]
    ON [dbo].[OutboxRecord]([DispatchedAt] ASC);

