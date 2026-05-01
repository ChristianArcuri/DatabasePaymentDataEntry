CREATE TABLE [dbo].[WebAgent_WireInPreparation_ValidationsDone] (
    [PreparationId]        UNIQUEIDENTIFIER NULL,
    [ValidationProvider]   VARCHAR (20)     NULL,
    [ValidationName]       VARCHAR (30)     NULL,
    [ValidationValue]      VARCHAR (200)    NULL,
    [ValidationDatetime]   DATETIME         NULL,
    [ValidationResult]     INT              NULL,
    [VerificationResponse] NVARCHAR (50)    NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_WebAgent_WireInPreparation_ValidationsDone]
    ON [dbo].[WebAgent_WireInPreparation_ValidationsDone]([PreparationId] ASC, [ValidationProvider] ASC, [ValidationName] ASC);

