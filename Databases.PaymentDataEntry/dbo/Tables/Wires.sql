CREATE TABLE [dbo].[Wires] (
    [WireId]                     INT              IDENTITY (1, 1) NOT NULL,
    [LSenderId]                  INT              NOT NULL,
    [LReceiverId]                INT              NOT NULL,
    [AgSenderId]                 INT              NOT NULL,
    [AgSenderCode]               VARCHAR (10)     NOT NULL,
    [AgSenderSeq]                INT              NOT NULL,
    [AgSenderState]              VARCHAR (80)     NOT NULL,
    [AgSenderCity]               VARCHAR (80)     NOT NULL,
    [AgSenderCountry]            VARCHAR (80)     NOT NULL,
    [AgPayerId]                  INT              NOT NULL,
    [AgPayerCode]                VARCHAR (10)     NOT NULL,
    [DestCountry]                VARCHAR (80)     NOT NULL,
    [DestState]                  VARCHAR (80)     NOT NULL,
    [DestCity]                   VARCHAR (80)     NOT NULL,
    [BranchId]                   INT              NOT NULL,
    [SenderId]                   INT              NOT NULL,
    [OnBehalfId]                 INT              NULL,
    [ReceiverId]                 INT              NOT NULL,
    [SenderName]                 VARCHAR (100)    NOT NULL,
    [OnBehalfName]               VARCHAR (100)    NULL,
    [ReceiverName]               VARCHAR (100)    NOT NULL,
    [PinNumber]                  VARCHAR (20)     NOT NULL,
    [WireDate]                   DATETIME         NOT NULL,
    [WireDatetime]               DATETIME         NOT NULL,
    [OriAmount]                  MONEY            NOT NULL,
    [OriCurrency]                CHAR (3)         NOT NULL,
    [Charges]                    MONEY            NOT NULL,
    [OtherChg]                   MONEY            NOT NULL,
    [AgencyFee]                  MONEY            NOT NULL,
    [OriToDestExRate]            MONEY            NOT NULL,
    [WireStateFee]               MONEY            NULL,
    [WireTotalAmount]            MONEY            NOT NULL,
    [DestAmount]                 MONEY            NOT NULL,
    [DestCurrency]               CHAR (3)         NOT NULL,
    [AgSenderCommission]         MONEY            NOT NULL,
    [TranTypeID]                 INT              NOT NULL,
    [AccountNumber]              VARCHAR (30)     NULL,
    [DeptBankName]               VARCHAR (60)     NULL,
    [AccountType]                SMALLINT         NULL,
    [DeptAdditionalInfo]         VARCHAR (60)     NULL,
    [BankBranchCode]             VARCHAR (7)      NULL,
    [DeliveryType]               CHAR (1)         NOT NULL,
    [SourceApp]                  INT              NOT NULL,
    [StsComplianceOk]            BIT              NOT NULL,
    [PossibleFraud]              BIT              CONSTRAINT [DF_Wires_PossibleFraud] DEFAULT ((0)) NOT NULL,
    [StsCancel]                  SMALLINT         CONSTRAINT [DF_Wires_StsCancel] DEFAULT ((0)) NOT NULL,
    [CustTrasactionID]           INT              NULL,
    [RateTypeID]                 INT              NOT NULL,
    [FeePlanID]                  INT              NULL,
    [FxPlanID]                   INT              NULL,
    [AgCommiPlanID]              INT              NULL,
    [FXDif]                      MONEY            NULL,
    [FXShare_id]                 INT              NULL,
    [ExRateMacro]                SMALLINT         NULL,
    [WirePurpose]                VARCHAR (200)    NULL,
    [FundSource]                 VARCHAR (120)    NULL,
    [Occupation]                 VARCHAR (80)     NULL,
    [IncomingPhoneNumber]        VARCHAR (20)     NULL,
    [CallerIDVerif]              BIT              NULL,
    [TeledirectWire]             BIT              NOT NULL,
    [NoFaxBackWire]              BIT              NOT NULL,
    [ReplacedControl]            INT              NULL,
    [WaivedCharges]              MONEY            NULL,
    [ReplaceWireRcvSel]          INT              NULL,
    [CustMessage]                VARCHAR (255)    NULL,
    [WireReplacementType]        SMALLINT         NOT NULL,
    [ReplacementReasonID]        INT              NULL,
    [MemberCardSwiped]           BIT              NULL,
    [SndDOB]                     DATETIME         NULL,
    [CreatedBy]                  VARCHAR (15)     NOT NULL,
    [ComputerName]               VARCHAR (30)     NOT NULL,
    [PayerPayMethodId]           INT              NULL,
    [SndRcvRelationship]         VARCHAR (80)     NULL,
    [NewTelewire]                BIT              CONSTRAINT [DF__Wires__NewTelewi__71D1E811] DEFAULT ((0)) NULL,
    [FxPointsAdded]              MONEY            CONSTRAINT [DF_Wires_FxPointsAdded] DEFAULT ((0)) NULL,
    [FXChangeCost]               MONEY            CONSTRAINT [DF_Wires_FXChangeCost] DEFAULT ((0)) NULL,
    [FXCostApplyTo]              CHAR (1)         NULL,
    [FeeChange]                  MONEY            NULL,
    [CostToAgent]                MONEY            NULL,
    [CostToCustomer]             MONEY            NULL,
    [FlexPrcOptionSelected]      CHAR (1)         NULL,
    [AgComputerid]               INT              NULL,
    [ComputerId]                 VARCHAR (200)    NULL,
    [DoneFromStation]            VARCHAR (50)     CONSTRAINT [DF_Wires_DoneFromStation] DEFAULT (host_name()) NULL,
    [DoneFromAppName]            VARCHAR (50)     CONSTRAINT [DF_Wires_DoneFromAppName] DEFAULT (app_name()) NULL,
    [DoneByUser]                 VARCHAR (50)     CONSTRAINT [DF_Wires_DoneByUser] DEFAULT (suser_sname()) NULL,
    [AppVersion]                 VARCHAR (50)     NULL,
    [DoneFromIP]                 VARCHAR (50)     NULL,
    [TkDelay]                    INT              NULL,
    [PayerSecToken]              INT              NULL,
    [ClientIP]                   VARCHAR (50)     NULL,
    [WireAvailableDate]          DATETIME         NULL,
    [CRMPromotionID]             INT              NULL,
    [SenderPromoUniqueKey]       VARCHAR (50)     NULL,
    [WirePoints]                 INT              NULL,
    [WirePointsSign]             INT              NULL,
    [WiresAlreadyCountGUID]      UNIQUEIDENTIFIER NULL,
    [PromoCostToAgent]           MONEY            CONSTRAINT [DF_Wires_PromoCostToAgent] DEFAULT ((0)) NULL,
    [PromoCostToPayer]           MONEY            CONSTRAINT [DF_Wires_PromoCostToPayer] DEFAULT ((0)) NULL,
    [DiscountAmount]             MONEY            CONSTRAINT [DF_Wires_DiscountAmount] DEFAULT ((0)) NULL,
    [PromoCostToCompany]         MONEY            CONSTRAINT [DF_Wires_PromoCostToCompany] DEFAULT ((0)) NOT NULL,
    [LoyaltyCardNumber]          VARCHAR (50)     NULL,
    [SenderPaymentMethodId]      INT              DEFAULT ((1)) NULL,
    [WireReadyToChargeSender]    BIT              DEFAULT ((1)) NULL,
    [WebAgentUserId]             INT              DEFAULT ((0)) NULL,
    [UserPaymentMethodInfoId]    INT              DEFAULT ((0)) NULL,
    [AccuLynkToken]              VARCHAR (20)     NULL,
    [WireIPAddress]              VARCHAR (50)     NULL,
    [WireFromState]              VARCHAR (40)     NULL,
    [IPDetectedState]            VARCHAR (40)     NULL,
    [WebAgentTransationId]       UNIQUEIDENTIFIER NULL,
    [StsSenderPaymentOk]         BIT              DEFAULT ((1)) NULL,
    [CollectionType]             VARCHAR (20)     NULL,
    [StsFraudCheckOk]            BIT              DEFAULT ((1)) NULL,
    [CollectionStatus]           INT              DEFAULT ((0)) NULL,
    [InstantAchOK]               BIT              DEFAULT ((0)) NULL,
    [CancelReasonId]             INT              DEFAULT ((0)) NULL,
    [StsUserKBAOk]               BIT              NULL,
    [AcumLoyaltyPoints]          BIT              NULL,
    [stsCreditOk]                BIT              DEFAULT ((1)) NULL,
    [DeviceFingerprint]          VARCHAR (50)     NULL,
    [SndEmployerName]            VARCHAR (120)    NULL,
    [SndEmployerPhone]           VARCHAR (20)     NULL,
    [SenderIdRecId]              INT              NULL,
    [AgencyExtraFee]             MONEY            CONSTRAINT [DF_Wires_AgencyExtraFee] DEFAULT ((0)) NULL,
    [WireSenderPaymentMethodFee] MONEY            CONSTRAINT [DF_Wires_WireSenderPaymentMethodFee] DEFAULT ((0)) NULL,
    [CashBackAmount]             MONEY            CONSTRAINT [DF_Wires_CashBackAmount] DEFAULT ((0)) NULL,
    [TransacTotalAmount]         MONEY            CONSTRAINT [DF_Wires_TransacTotalAmount] DEFAULT ((0)) NULL,
    [CardChargeId]               INT              CONSTRAINT [DF_Wires_CardChargeId] DEFAULT ((0)) NULL,
    [ChannelId]                  INT              CONSTRAINT [DF__Wires__ChannelId__76B698BF] DEFAULT ((0)) NULL,
    [PartnerId]                  INT              CONSTRAINT [DF__Wires__PartnerId__77AABCF8] DEFAULT ((0)) NULL,
    [AgPayerRcvIdTypeRecordId]   INT              DEFAULT ((0)) NULL,
    [RcvIdNumber]                VARCHAR (80)     NULL,
    [CardDirectProvider]         INT              NULL,
    [F1025AgentFullName]         VARCHAR (150)    DEFAULT ('') NULL,
    [AgencyPricingId]            INT              NULL,
    [AgencyPricingDetailId]      INT              NULL,
    [FxBaseId]                   INT              NULL,
    [FXPromotionId]              INT              NULL,
    [FxBase]                     MONEY            NULL,
    [AgencyFXPointsFromBase]     MONEY            NULL,
    [AgencyPromoFXPoints]        MONEY            NULL,
    [FXBasePromotionId]          INT              DEFAULT ((0)) NULL,
    [FxBasePromotion]            MONEY            DEFAULT ((0)) NULL,
    [StyleId]                    INT              DEFAULT ((0)) NULL,
    [PartnerAgencyCode] VARCHAR(10) NULL, 
    CONSTRAINT [PK_Wires] PRIMARY KEY CLUSTERED ([WireId] ASC) WITH (FILLFACTOR = 80)
);




GO
CREATE NONCLUSTERED INDEX [idx_Wires_WireDate]
    ON [dbo].[Wires]([WireDate] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Wires_AgencyCode_AgSenderSeq]
    ON [dbo].[Wires]([AgSenderCode] ASC, [AgSenderSeq] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [ix_Wires_PinNumber]
    ON [dbo].[Wires]([PinNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Wires_AgSenderCode_ReceiverName]
    ON [dbo].[Wires]([AgSenderCode] ASC, [ReceiverName] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Wires_AgSenderCode_SenderName]
    ON [dbo].[Wires]([AgSenderCode] ASC, [SenderName] ASC);


GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trg_Wire_delete]
   ON dbo.Wires 
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON

     if exists(select * from deleted where WireDate > dbo.DateOnly(GetDate() - 15))
       begin
		 rollback
		 RAISERROR ('Wires cannot be deleted', 16, 1)
       end

END

GO
create TRIGGER trg_Wire_Insert
   ON  dbo.Wires
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

    UPDATE Wires with(updlock) set DoneFromIP = dbo.GetCurrentIP()
    WHERE WireId in (select WireId from inserted) 
END
