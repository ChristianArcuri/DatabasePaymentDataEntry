CREATE TABLE [dbo].[WebAgent_InstantACHParameters] (
    [RecordId]  INT          IDENTITY (1, 1) NOT NULL,
    [RecType]   VARCHAR (10) NULL,
    [FromWires] INT          NULL,
    [ToWires]   INT          NULL,
    [MaxAmount] MONEY        NULL,
    CONSTRAINT [PK_WebAgent_InstantACHParameters] PRIMARY KEY CLUSTERED ([RecordId] ASC)
);

