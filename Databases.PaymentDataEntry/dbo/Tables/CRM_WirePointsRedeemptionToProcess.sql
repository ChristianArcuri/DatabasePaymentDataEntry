CREATE TABLE [dbo].[CRM_WirePointsRedeemptionToProcess] (
    [RecordId]           INT          IDENTITY (1, 1) NOT NULL,
    [AgSenderCode]       VARCHAR (10) NULL,
    [AgSenderSeq]        INT          NULL,
    [Control]            INT          NULL,
    [SameSenderId]       INT          NULL,
    [PointsToRedeem]     INT          NULL,
    [PointsRedemptionId] INT          NULL,
    [Processed]          DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([RecordId] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [ix_CRM_WirePointsRedeemptionToProcess]
    ON [dbo].[CRM_WirePointsRedeemptionToProcess]([Processed] ASC, [Control] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_CRM_WirePointsRedeemptionToProcess_2]
    ON [dbo].[CRM_WirePointsRedeemptionToProcess]([Processed] ASC, [AgSenderCode] ASC, [AgSenderSeq] ASC) WITH (FILLFACTOR = 90);

