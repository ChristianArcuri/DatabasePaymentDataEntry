CREATE TABLE [dbo].[WebAgent_WireInPreparation_FXDetail] (
    [RecordId]      INT              IDENTITY (1, 1) NOT NULL,
    [PreparationId] UNIQUEIDENTIFIER NULL,
    [AgPayerCode]   VARCHAR (10)     NULL,
    [ExRate]        FLOAT (53)       NULL,
    [DestCurrency]  VARCHAR (3)      NULL,
    [TranTypeId]    INT              NULL,
    [FlagGroupName] BIT              DEFAULT ((0)) NULL,
    [FxGroupName]   VARCHAR (30)     DEFAULT ('') NULL,
    CONSTRAINT [PK_WebAgent_WireInPreparation_FXDetail] PRIMARY KEY CLUSTERED ([RecordId] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_PreparationFXDetail_PreparationIdPayer]
    ON [dbo].[WebAgent_WireInPreparation_FXDetail]([PreparationId] ASC, [AgPayerCode] ASC);

