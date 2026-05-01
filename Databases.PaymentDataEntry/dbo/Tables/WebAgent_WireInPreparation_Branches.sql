CREATE TABLE [dbo].[WebAgent_WireInPreparation_Branches] (
    [RecordId]              INT              IDENTITY (1, 1) NOT NULL,
    [PreparationId]         UNIQUEIDENTIFIER NOT NULL,
    [CurrentWebLanguageId]  INT              NULL,
    [DestCountry]           VARCHAR (30)     NULL,
    [TranTypeId]            INT              NULL,
    [OriAmount]             MONEY            NULL,
    [OriCurrency]           CHAR (3)         NULL,
    [DestAmount]            MONEY            NULL,
    [DestCurrency]          CHAR (3)         NULL,
    [DisplayOrder]          INT              NULL,
    [AgPayerCode]           VARCHAR (10)     NULL,
    [AgPayerId]             INT              NULL,
    [AgPayerName]           VARCHAR (40)     NULL,
    [MustSelectBranch]      BIT              NULL,
    [HomeDeliveryAvailable] BIT              NULL,
    [BrState]               VARCHAR (30)     NULL,
    [BrCity]                VARCHAR (40)     NULL,
    [BranchId]              INT              NULL,
    [BrPlaceName]           VARCHAR (40)     NULL,
    [BrAddress]             VARCHAR (70)     NULL,
    [MonFriHours]           VARCHAR (35)     NULL,
    [SatHours]              VARCHAR (35)     NULL,
    [SunHours]              VARCHAR (35)     NULL,
    [DeliveryType]          CHAR (1)         DEFAULT ('') NULL,
    CONSTRAINT [PK_WebAgent_WireInPreparation_Branches_new] PRIMARY KEY CLUSTERED ([RecordId] ASC)
);






GO







GO
CREATE NONCLUSTERED INDEX [IX_WebAgent_WireInPreparation_Branches_PreparationId]
    ON [dbo].[WebAgent_WireInPreparation_Branches]([PreparationId] ASC, [DestCountry] ASC, [BrState] ASC, [BrCity] ASC, [AgPayerCode] ASC);

