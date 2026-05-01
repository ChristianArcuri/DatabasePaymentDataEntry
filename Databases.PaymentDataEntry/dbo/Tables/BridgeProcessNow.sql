CREATE TABLE [dbo].[BridgeProcessNow] (
    [DoItNow] BIT CONSTRAINT [DF_BridgeProcessNow_DoItNow] DEFAULT ((0)) NOT NULL
);

