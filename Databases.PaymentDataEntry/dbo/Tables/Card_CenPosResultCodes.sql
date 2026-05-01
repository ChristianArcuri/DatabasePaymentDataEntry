CREATE TABLE [dbo].[Card_CenPosResultCodes] (
    [ResultCode]          INT            NOT NULL,
    [InternalDescription] VARCHAR (100)  NOT NULL,
    [ResultMessage]       VARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_Card_CenPosResultCodes] PRIMARY KEY CLUSTERED ([ResultCode] ASC)
);

