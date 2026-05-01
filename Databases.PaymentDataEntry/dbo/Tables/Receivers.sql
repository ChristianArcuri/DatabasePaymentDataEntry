CREATE TABLE [dbo].[Receivers] (
    [LReceiverId]        INT           IDENTITY (1, 1) NOT NULL,
    [ReceiverId]         INT           NOT NULL,
    [ReceiverGroupId]    INT           CONSTRAINT [DF_Receivers_ReceiverGroupId] DEFAULT ((0)) NOT NULL,
    [RcvFullName]        VARCHAR (150) NOT NULL,
    [RcvFirstName]       VARCHAR (50)  NOT NULL,
    [RcvLast1]           VARCHAR (50)  NOT NULL,
    [RcvLast2]           VARCHAR (50)  NULL,
    [RcvAddress]         VARCHAR (200) NOT NULL,
    [RcvCountry]         VARCHAR (30)  NOT NULL,
    [RcvState]           VARCHAR (30)  NOT NULL,
    [RcvCity]            VARCHAR (40)  NOT NULL,
    [RcvZip]             VARCHAR (15)  NULL,
    [RcvPhone]           VARCHAR (20)  NULL,
    [RcvNoSecLastName]   BIT           NOT NULL,
    [RcvLastVersionID]   INT           NOT NULL,
    [CPF]                VARCHAR (11)  NULL,
    [Entered]            DATETIME      CONSTRAINT [DF_Receivers_Entered] DEFAULT (getdate()) NOT NULL,
    [RcvDOB]             DATE          NULL,
    [IsCellPhone]        BIT           DEFAULT ((0)) NULL,
    [RcvAdditionalPhone] VARCHAR (20)  NULL,
    CONSTRAINT [PK_Receivers] PRIMARY KEY CLUSTERED ([LReceiverId] ASC) WITH (FILLFACTOR = 80)
);

