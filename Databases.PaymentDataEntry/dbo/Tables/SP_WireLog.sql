CREATE TABLE [dbo].[SP_WireLog] (
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
    [UserName]     VARCHAR (50)  CONSTRAINT [DF_SP_WireLog_UserName] DEFAULT (suser_sname()) NULL,
    [SP]           INT           NULL,
    CONSTRAINT [PK_WireLog] PRIMARY KEY CLUSTERED ([RecordId] ASC)
);

