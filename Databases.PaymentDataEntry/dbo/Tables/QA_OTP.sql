CREATE TABLE [dbo].[QA_OTP] (
    [ID]             INT          IDENTITY (1, 1) NOT NULL,
    [AgencyCode]     VARCHAR (20) NOT NULL,
    [AgComputerName] VARCHAR (50) NOT NULL,
    [AgComputerTime] DATETIME     NOT NULL,
    [OTPRefTime]     DATETIME     NOT NULL,
    [CurrServerTime] DATETIME     CONSTRAINT [DF_QA_OTP_CurrServerTime] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_QA_OTP] PRIMARY KEY CLUSTERED ([ID] ASC)
);

