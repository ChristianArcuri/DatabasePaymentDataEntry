CREATE TABLE [dbo].[BanamexWires] (
    [WireId]      INT NOT NULL,
    [PromotionId] INT NULL,
    CONSTRAINT [PK_BanamexWires] PRIMARY KEY CLUSTERED ([WireId] ASC) WITH (FILLFACTOR = 80)
);

