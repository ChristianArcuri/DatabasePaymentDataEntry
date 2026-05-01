CREATE TABLE dbo.SenderPartner
  (
    SenderPartnerID INT NOT NULL
  , LSenderID        INT NOT NULL
  , SenderID        INT NOT NULL
  , SndLastVersionId  INT NOT NULL
  , SenderGroupId   INT NOT NULL
  , Partner         INT NOT NULL
  , CONSTRAINT PK_SenderPartner PRIMARY KEY (SenderPartnerID, Partner)
  )
