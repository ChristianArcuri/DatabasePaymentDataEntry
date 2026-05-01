CREATE TABLE [dbo].[WebAgent_WireGeolocationInfo] (
    [GeolocationInfoId]   INT              IDENTITY (1, 1) NOT NULL,
    [PreparationId]       UNIQUEIDENTIFIER NOT NULL,
    [TransactionId]       UNIQUEIDENTIFIER NULL,
    [Control]             INT              NULL,
    [IpAddress]           VARCHAR (50)     NULL,
    [IsSuccessful]        BIT              NOT NULL,
    [ErrorMessage]        VARCHAR (4000)   NULL,
    [CityName]            VARCHAR (100)    NULL,
    [CityConfidence]      INT              NULL,
    [Continent]           VARCHAR (100)    NULL,
    [CountryName]         VARCHAR (100)    NULL,
    [CountryCode]         VARCHAR (10)     NULL,
    [CountryConfidence]   INT              NULL,
    [StateName]           VARCHAR (100)    NULL,
    [StateCode]           VARCHAR (10)     NULL,
    [StateConfidence]     INT              NULL,
    [Latitude]            DECIMAL (18, 6)  NULL,
    [Longitude]           DECIMAL (18, 6)  NULL,
    [TimeZone]            VARCHAR (50)     NULL,
    [ZipCode]             VARCHAR (10)     NULL,
    [ZipCodeConfidence]   INT              NULL,
    [Domain]              VARCHAR (100)    NULL,
    [Organization]        VARCHAR (100)    NULL,
    [ISP]                 VARCHAR (100)    NULL,
    [UserType]            VARCHAR (50)     NULL,
    [XmlData]             VARCHAR (MAX)    NULL,
    [SentToMain]          BIT              DEFAULT ((0)) NULL,
    [VendorTransactionId] INT              DEFAULT ((0)) NULL,
    CONSTRAINT [PK_WebAgent_WireGeolocationInfo] PRIMARY KEY CLUSTERED ([GeolocationInfoId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_WebAgent_WireGeolocationInfo_PreparationId]
    ON [dbo].[WebAgent_WireGeolocationInfo]([PreparationId] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_WebAgent_WireGeolocationInfo_TransactionId]
    ON [dbo].[WebAgent_WireGeolocationInfo]([TransactionId] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_WebAgent_WireGeolocationInfo]
    ON [dbo].[WebAgent_WireGeolocationInfo]([SentToMain] ASC);

GO
CREATE NONCLUSTERED INDEX IX_WebAgent_WireGeolocationInfo__ViewGeoLocation
ON [dbo].[WebAgent_WireGeolocationInfo] ([CountryCode],[StateName],[Latitude],[Longitude])
INCLUDE ([CityName],[Continent],[CountryName],[StateCode],[TimeZone],[ZipCode]);

