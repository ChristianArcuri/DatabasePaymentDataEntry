CREATE TABLE [dbo].[WebAgent_TimeLog] (
    [recordid]             INT              IDENTITY (1, 1) NOT NULL,
    [WebAgentTransationId] UNIQUEIDENTIFIER NULL,
    [d]                    DATETIME         NULL,
    [pinnumber]            VARCHAR (20)     NULL,
    PRIMARY KEY CLUSTERED ([recordid] ASC)
);

