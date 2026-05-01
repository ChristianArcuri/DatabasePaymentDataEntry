CREATE TABLE [dbo].[WirePossibleFraud] (
    [ID]                    INT           IDENTITY (1, 1) NOT NULL,
    [WireId]                INT           NOT NULL,
    [S]                     INT           CONSTRAINT [DF_WirePossibleFraud_S] DEFAULT ((0)) NOT NULL,
    [Ok]                    BIT           CONSTRAINT [DF_WirePossibleFraud_Ok] DEFAULT ((0)) NULL,
    [TokenResult]           INT           NULL,
    [Token]                 VARCHAR (200) NULL,
    [InvalidUser]           BIT           NULL,
    [WrongPassword]         BIT           NULL,
    [WrongAppHash]          BIT           NULL,
    [InvalidConnectionUser] BIT           NULL,
    [ComputerNotAuth]       BIT           NULL,
    [InvalidSPToken]        BIT           NULL,
    [NoLogin]               BIT           NULL,
    [EmailSent]             DATETIME      NULL,
    [Created]               DATETIME      CONSTRAINT [DF_WirePossibleFraud_Created] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WirePossibleFraud] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [idx_WirePossibleFraud_WireId]
    ON [dbo].[WirePossibleFraud]([WireId] ASC);

