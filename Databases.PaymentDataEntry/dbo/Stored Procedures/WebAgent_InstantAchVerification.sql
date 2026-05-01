
CREATE PROCEDURE [dbo].[WebAgent_InstantAchVerification]
@WebAgentUserId int,
@UserPaymentMethodInfoId int,
@WireTotalAmount money,
@StsFraudCheckOk bit,
@InstantAchOK bit OUTPUT     
AS
BEGIN

  DECLARE @IsEmployee bit
  DECLARE @WireAmountLimit money
  DECLARE @AccountCumLimit money
  DECLARE @UserAmountLimit_ACH money
  DECLARE @UserAmountLimit_Total MONEY



  DECLARE @UserCumAmount_ACH money
  DECLARE @UserCumAmount_Total money
  DECLARE @AccCumAmount money


  DECLARE @AbaCode varchar(9)
  DECLARE @AccountNumber varchar(20)
  DECLARE @QWireCleared int
  DECLARE @today datetime = dbo.dateonly(getdate())
  
  select @IsEmployee = IsEmployee
    From WireSecurity.dbo.WebAgent_Users
   Where WebAgentUserId = @WebAgentUserId


  SET @InstantAchOK = 0

  IF @StsFraudCheckOk = 0 and @IsEmployee = 0 --Si esta retenido por Fraude, y no es empleado interno devuelve FALSE
     RETURN

  IF @IsEmployee = 1  ---Por orden de Kim el 28 de abril, los empleado que envian menos de 1000 se les autoriza instant ach
 and @WireTotalAmount <= 1000
     BEGIN
	   SET @InstantAchOK = 1
	   RETURN
	 END

  		
 --Tomar en cuenta Charge Backs para no darle instant ach
  IF EXISTS (Select 1 FROM SqlMain.WireTransac.dbo.WebAgent_CollectionReturnDetail
              Where WebAgentUserId = @WebAgentUserId)
	 BEGIN
	   RETURN
	 END

-- Obtengo la cantidad de giros clareados de este usuario con esta misma cuenta de banco
   
   Select @AbaCode       = AbaCode, 
          @AccountNumber = AccountNumber
     from SqlMain.WireTransac.dbo.WebAgent_UserPaymentMethodInfo
    where UserPaymentMethodInfoId  = @UserPaymentMethodInfoId


	--Se cambia a pedido de Kim, en vez de cantidad de giros clareados de la misma cuenta de banco
   --select @QWireCleared = COUNT(*)
   --  from SqlMain.WireTransac.dbo.webagent_wires as wa
   --       inner join SqlMain.WireTransac.dbo.wires as w on wa.control = w.control
   --       inner join SqlMain.WireTransac.dbo.WebAgent_UserPaymentMethodInfo as i on wa.UserPaymentMethodInfoId = i.UserPaymentMethodInfoId
   -- Where wa.WebAgentUserId = @WebAgentUserId
	  --and wa.CollectionStatus = 3
   --   and i.SenderPaymentMethodId = 2 --ACH
   --   and w.StsCancel     = 0
   --   and i.AbaCode       = @AbaCode
   --   and i.AccountNumber = @AccountNumber


	  --- Quantity of successful transactions via ach or debit card for risk period finished.
	Select @QWireCleared = count(*) 
	  from SqlMain.WireTransac.dbo.wires as w
	       inner join SqlMain.WireTransac.dbo.webagent_wires as w1 on w.control = w1.control
	       inner join WireSearch.dbo.WebAgent_SenderPaymentMethods as m on w.SenderPaymentMethodId = m.SenderPaymentMethodId
	 Where w1.webagentuserid   = @WebAgentUserId
	   and w1.wiredate        <= dateadd(dd,m.chargebackriskdays*-1,@today) 
	   and w1.CollectionStatus = 3 --Collected
	   and w.senderpaymentmethodid in (2,3) --Ach or Debit Card
	   and w.stscancel         = 0
 

	  ---==========GET MAX AMOUNTS =======================
 
  SELECT @WireAmountLimit = MaxAmount
    FROM WebAgent_InstantACHParameters
   WHERE RecType = 'WIRE'
	 AND @QWireCleared BETWEEN FromWires AND ToWires
  IF @@ROWCOUNT = 0 
     SET @WireAmountLimit = 0


   SELECT @UserAmountLimit_ACH = MaxAmount
    FROM WebAgent_InstantACHParameters
   WHERE RecType = 'USER_ACH'
	 AND @QWireCleared BETWEEN FromWires AND ToWires
   IF @@ROWCOUNT = 0 
     SET @UserAmountLimit_ACH = 0

   SELECT @UserAmountLimit_Total = MaxAmount
    FROM WebAgent_InstantACHParameters
   WHERE RecType = 'USER_TOTAL'
	 AND @QWireCleared BETWEEN FromWires AND ToWires
  IF @@ROWCOUNT = 0 
     SET @UserAmountLimit_Total = 0

  SELECT @AccountCumLimit = MaxAmount
    FROM WebAgent_InstantACHParameters
   WHERE RecType = 'ACCOUNT'
	 AND @QWireCleared BETWEEN FromWires AND ToWires
  IF @@ROWCOUNT = 0 
     SET @AccountCumLimit = 0
	 
	 --PRINT @WireAmountLimit
	 --PRINT @UserAmountLimit_ACH
	 --PRINT @UserAmountLimit_Total
	 --PRINT @AccountCumLimit
	 --PRINT @QWireCleared
--==-------------------------------------------------
   

  IF @WireTotalAmount > @WireAmountLimit                ----Limite x Giro
     RETURN


  select @UserCumAmount_ACH = SUM(w.WireTotalAmount)
    from SqlMain.WireTransac.dbo.webagent_wires as wa
         inner join SqlMain.WireTransac.dbo.wires as w on wa.control = w.control
   Where wa.WebAgentUserId       = @WebAgentUserId
     and wa.CollectionType       = 'InstantACH'
     and wa.CollectionStatus in (0,2) --Pending,AchProcessed
     and w.SenderPaymentMethodId = 2 --ACH
     and w.StsCancel             = 0

   IF ISNULL(@UserCumAmount_ACH,0) > @UserAmountLimit_ACH ---Acumulado de ACH en transito del Usuario
      RETURN
   

   select @UserCumAmount_Total = SUM(w.WireTotalAmount)
    from SqlMain.WireTransac.dbo.webagent_wires as wa
         inner join SqlMain.WireTransac.dbo.wires as w on wa.control = w.control
   Where wa.WebAgentUserId       = @WebAgentUserId
     and wa.CollectionStatus <> 3 --No cobrado todavia
     and w.SenderPaymentMethodId in( 2,3,4) --ACH
     and w.StsCancel             = 0

   IF ISNULL(@UserCumAmount_Total,0) > @UserAmountLimit_Total ---Acumulado Total No cobrado del Usuario
      RETURN


   select @AccCumAmount = SUM(w.WireTotalAmount)
     from SqlMain.WireTransac.dbo.webagent_wires as wa
          inner join SqlMain.WireTransac.dbo.wires as w on wa.control = w.control
          inner join SqlMain.WireTransac.dbo.WebAgent_UserPaymentMethodInfo as i on wa.UserPaymentMethodInfoId = i.UserPaymentMethodInfoId
    Where wa.CollectionType = 'InstantACH'
      and wa.CollectionStatus in (0,2) --Pending,AchProcessed
      and i.SenderPaymentMethodId = 2 --ACH
      and w.StsCancel     = 0
      and i.AbaCode       = @AbaCode
      and i.AccountNumber = @AccountNumber

   IF ISNULL(@AccCumAmount,0) > @AccountCumLimit ---Acumulado en transito de la Cuenta de Banco
      RETURN
 

   


  SET @InstantAchOK = 1
END