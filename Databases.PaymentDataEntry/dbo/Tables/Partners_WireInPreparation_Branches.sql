CREATE TABLE [dbo].[Partners_WireInPreparation_Branches]
(
    [PartnerId] INT NOT NULL, 
    [BranchId] INT NOT NULL, 
    [PartnerBranchCode] VARCHAR(7) NOT NULL,  
    [BrName] VARCHAR(40) NOT NULL
    PRIMARY KEY ([PartnerId],[BranchId])
)