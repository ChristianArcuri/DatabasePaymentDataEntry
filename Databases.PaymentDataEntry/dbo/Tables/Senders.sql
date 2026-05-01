CREATE TABLE [dbo].[Senders] (
    [LSenderId]           INT           IDENTITY (1, 1) NOT NULL,
    [SenderId]            INT           NOT NULL,
    [SenderGroupId]       INT           CONSTRAINT [DF_Senders_SenderGroupId] DEFAULT ((0)) NOT NULL,
    [SndFullName]         VARCHAR (150) NOT NULL,
    [SndFirstName]        VARCHAR (50)  NOT NULL,
    [SndLast1]            VARCHAR (50)  NOT NULL,
    [SndLast2]            VARCHAR (50)  NULL,
    [SndAddress]          VARCHAR (50)  NOT NULL,
    [SndCountry]          VARCHAR (30)  NOT NULL,
    [SndState]            VARCHAR (30)  NOT NULL,
    [SndCity]             VARCHAR (40)  NOT NULL,
    [SndZip]              VARCHAR (15)  NOT NULL,
    [SndPhone]            VARCHAR (20)  NOT NULL,
    [SndLastVersionId]    INT           NOT NULL,
    [SndNoSecLastName]    BIT           CONSTRAINT [DF_Senders_SndNoSecLastName] DEFAULT ((0)) NOT NULL,
    [SndIdTypeName]       VARCHAR (50)  NULL,
    [SndIdNumber]         VARCHAR (80)  NULL,
    [SndIdCountry]        VARCHAR (30)  NULL,
    [SndIdState]          VARCHAR (40)  NULL,
    [SndIdExpirationDate] DATETIME      NULL,
    [Entered]             DATETIME      CONSTRAINT [DF_Senders_Entered] DEFAULT (getdate()) NOT NULL,
    [SndEmail]            VARCHAR (150) NULL,
    [IsCellPhone]         BIT           NULL,
    [OptStatus]           CHAR (1)      NULL,
    [OptStatusDate]       DATETIME      NULL,
    [WebAgentUserId]      INT           DEFAULT ((0)) NULL,
    [Citizenship]         VARCHAR (40)  NULL,
    [SndAdditionalPhone]  VARCHAR (20)  NULL,
    [OptStatusPromo]      CHAR (1)      DEFAULT ('') NULL,
    CONSTRAINT [PK_Senders] PRIMARY KEY CLUSTERED ([LSenderId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Senders_Senders] FOREIGN KEY ([LSenderId]) REFERENCES [dbo].[Senders] ([LSenderId])
);


GO
CREATE NONCLUSTERED INDEX [IDX_Senders_SenderID]
    ON [dbo].[Senders]([SenderId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IDX_Senders_FullName_Addr]
    ON [dbo].[Senders]([SndFullName] ASC, [SndAddress] ASC, [SndState] ASC, [LSenderId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [iX_Senders_WebAgentUserId]
    ON [dbo].[Senders]([WebAgentUserId] ASC);

