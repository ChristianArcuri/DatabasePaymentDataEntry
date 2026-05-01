CREATE procedure [dbo].[InsTest]
@S varchar(200)
as
begin

declare @D datetime

set @D = GETDATE()

INSERT INTO [PaymentDataEntry].[dbo].[TEST]
           ([Msg]
           ,[NUM]
           ,[CREATED])
     VALUES
           (@S,
           1,
           @D)
end


