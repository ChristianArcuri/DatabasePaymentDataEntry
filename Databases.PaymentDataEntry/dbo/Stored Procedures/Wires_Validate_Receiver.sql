/*
=============================================
Author: Borelli Elias
Create date: 2023-10-10
Description: Returns if receiver is valid.
=============================================
*/

CREATE PROCEDURE dbo.Wires_Validate_Receiver
	@RcvAddress Varchar(200) = NULL,
	@RcvCity Varchar(60) = NULL,                          
	@RcvCountry Varchar(80) = NULL,           
	@RcvFirstName Varchar(50) = NULL,          
	@RcvLast1 Varchar(50) = NULL,                                
	@RcvState Varchar(40) = NULL,               
    --OUTPUTS
    @ValidResult INT OUTPUT,
    @ErrorCode varchar(10) OUTPUT,
	@FocusFieldName VARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        SET XACT_ABORT ON;
		SET NOCOUNT ON;
        
        SET @ValidResult = 0
        
        IF @RcvAddress IS NULL OR UPPER(LTRIM(RTRIM(@RcvAddress))) = ''
        BEGIN
        	SET @ValidResult = 1
        	SET @ErrorCode = '11131' 
			SET @FocusFieldName = 'Receiver Address'
			RETURN	
        END
        
        IF @RcvCity IS NULL OR UPPER(LTRIM(RTRIM(@RcvCity))) = ''
        BEGIN
        	SET @ValidResult = 1
        	SET @ErrorCode = '10817' 
			SET @FocusFieldName = 'Receiver City'
			RETURN	
        END
        
        IF @RcvCountry IS NULL OR UPPER(LTRIM(RTRIM(@RcvCountry))) = ''
        BEGIN
        	SET @ValidResult = 1
        	SET @ErrorCode = '1672' 
			SET @FocusFieldName = 'Receiver Country'
			RETURN	
        END
        
        IF @RcvFirstName IS NULL OR UPPER(LTRIM(RTRIM(@RcvFirstName))) = ''
        BEGIN
        	SET @ValidResult = 1
        	SET @ErrorCode = '10813' 
			SET @FocusFieldName = 'Receiver FirstName'
			RETURN	
        END
        
        IF @RcvLast1 IS NULL OR UPPER(LTRIM(RTRIM(@RcvLast1))) = ''
        BEGIN
        	SET @ValidResult = 1
        	SET @ErrorCode = '10814'
			SET @FocusFieldName = 'Receiver Last1'
			RETURN	
        END
        
        IF @RcvState IS NULL OR UPPER(LTRIM(RTRIM(@RcvState))) = ''
        BEGIN
        	SET @ValidResult = 1
        	SET @ErrorCode = '10816' 
			SET @FocusFieldName = 'Receiver State'
			RETURN	
        END
		
    END TRY
    BEGIN CATCH
        SET @ValidResult = 1
    END CATCH
END
GO
