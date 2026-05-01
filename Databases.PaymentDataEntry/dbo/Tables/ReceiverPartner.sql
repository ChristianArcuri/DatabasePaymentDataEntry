CREATE TABLE dbo.ReceiverPartner
  (
    ReceiverPartnerID INT NOT NULL
  , LReceiverID       INT NOT NULL
  , ReceiverID        INT NOT NULL
  , RcvLastVersionId  INT NOT NULL
  , ReceiverGroupId   INT NOT NULL
  , Partner           INT NOT NULL
  , CONSTRAINT PK_ReceiverPartner PRIMARY KEY (ReceiverPartnerID, Partner)
  )
