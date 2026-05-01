CREATE TABLE [dbo].[Card_CenposKioskResults] (
    [ResultId]     INT           IDENTITY (1, 1) NOT NULL,
    [WireTAG]      VARCHAR (20)  NOT NULL,
    [JsonRequest]  VARCHAR (MAX) NULL,
    [JsonResponse] VARCHAR (MAX) NULL,
    [ErrorMessage] VARCHAR (MAX) NULL,
    [Created]      DATETIME      NULL,
    CONSTRAINT [PK_Card_CenposKioskResults] PRIMARY KEY CLUSTERED ([ResultId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Card_CenposKioskResults_WireTag]
    ON [dbo].[Card_CenposKioskResults]([WireTAG] ASC);

