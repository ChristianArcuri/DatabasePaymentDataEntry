CREATE TABLE [dbo].[WiresToFax] (
    [ID]      INT      IDENTITY (1, 1) NOT NULL,
    [WireId]  INT      NOT NULL,
    [Fax1025] BIT      CONSTRAINT [DF_WiresToFax_Fax1025] DEFAULT ((0)) NOT NULL,
    [Faxed]   DATETIME NULL,
    [Created] DATETIME CONSTRAINT [DF_WiresToFax_Created] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WiresToFax] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_WiresFax_Faxed]
    ON [dbo].[WiresToFax]([Faxed] ASC);

