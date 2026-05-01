CREATE TABLE [dbo].[WebAgent_CleanPreparations] (
    [PreparationId] UNIQUEIDENTIFIER NULL,
    [Created]       DATETIME         CONSTRAINT [DF_WebAgent_CleanPreparations_Created] DEFAULT (getdate()) NULL
);

