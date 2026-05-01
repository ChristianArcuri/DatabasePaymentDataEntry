CREATE TABLE [dbo].[WiresPurposes] (
    [Id]            INT IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [WireId]        INT NOT NULL,
    [WirePurposeId] INT NOT NULL,
    CONSTRAINT [PK_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);

