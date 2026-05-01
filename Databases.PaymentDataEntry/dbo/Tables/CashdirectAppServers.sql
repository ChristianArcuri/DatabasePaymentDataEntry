CREATE TABLE [dbo].[CashdirectAppServers] (
    [IPAddress] VARCHAR (50) NOT NULL,
    [SrvName]   VARCHAR (50) NOT NULL,
    [Location]  VARCHAR (50) NOT NULL,
    [InProd]    BIT          CONSTRAINT [DF_CashdirectAppServers_InProd] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CashdirectAppServers] PRIMARY KEY CLUSTERED ([IPAddress] ASC)
);

