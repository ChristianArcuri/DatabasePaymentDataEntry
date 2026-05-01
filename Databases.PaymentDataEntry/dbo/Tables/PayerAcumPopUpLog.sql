CREATE TABLE [dbo].[PayerAcumPopUpLog] (
    [PayerAcumPopUpId] INT           IDENTITY (1, 1) NOT NULL,
    [AgPayercode]      VARCHAR (10)  NULL,
    [ReceiverName]     VARCHAR (150) NULL,
    [WireAmount]       MONEY         NULL,
    [AvailableAmount]  MONEY         NULL,
    [OptionSelected]   CHAR (2)      CONSTRAINT [DF_PayerAcumPopUpLog_OptionSelected] DEFAULT ('') NULL,
    [WireId]           INT           CONSTRAINT [DF_PayerAcumPopUpLog_WireId] DEFAULT ((0)) NULL,
    [SourceApp]        INT           NULL,
    [Created]          DATETIME      CONSTRAINT [DF_PayerAcumPopUpLog_Created] DEFAULT (getdate()) NULL,
    [CreatedBy]        VARCHAR (15)  NULL,
    CONSTRAINT [PK_PayerAcumPopUpLog] PRIMARY KEY CLUSTERED ([PayerAcumPopUpId] ASC) WITH (FILLFACTOR = 80)
);

