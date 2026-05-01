CREATE TABLE [dbo].[FAlert] (
    [RecordId]     INT           IDENTITY (1, 1) NOT NULL,
    [AgSenderCode] VARCHAR (10)  NULL,
    [SenderName]   VARCHAR (150) NULL,
    [ReceiverName] VARCHAR (150) NULL,
    [OriAmount]    MONEY         NULL,
    [AgPayerCode]  VARCHAR (10)  NULL,
    [CreatedBy]    VARCHAR (15)  NULL,
    [WireDateTime] DATETIME      NULL,
    [ComputerName] VARCHAR (20)  NULL,
    [IPAddress]    VARCHAR (100) NULL,
    [UserName]     VARCHAR (50)  CONSTRAINT [DF_FAlert_UserName] DEFAULT (suser_sname()) NULL,
    [Notified]     DATETIME      NULL,
    [Created]      DATETIME      CONSTRAINT [DF_FAlert_Created] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_FAlert] PRIMARY KEY CLUSTERED ([RecordId] ASC) WITH (FILLFACTOR = 80)
);

