CREATE TABLE [dbo].[TEMP_Token] (
    [ID]      INT           IDENTITY (1, 1) NOT NULL,
    [WireTAG] CHAR (15)     NULL,
    [Token]   VARCHAR (200) NULL,
    CONSTRAINT [PK_TEMP_Token] PRIMARY KEY CLUSTERED ([ID] ASC)
);

