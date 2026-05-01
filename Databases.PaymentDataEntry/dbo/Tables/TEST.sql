CREATE TABLE [dbo].[TEST] (
    [ID]      INT           IDENTITY (1, 1) NOT NULL,
    [Msg]     VARCHAR (MAX) NULL,
    [NUM]     INT           NULL,
    [N1]      MONEY         NULL,
    [N2]      MONEY         NULL,
    [CREATED] DATETIME      CONSTRAINT [DF_TEST_CREATED] DEFAULT (getdate()) NOT NULL
);

