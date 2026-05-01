/*
=============================================
Author: Borelli Elias
Create date: 2023-10-10
Description: Returns if sender is valid.
=============================================
*/

CREATE PROCEDURE dbo.Wires_Validate_Sender
	@SndAddress Varchar(50) = NULL,
	@SndCity Varchar(60) = NULL,
	@SndCountry Varchar(80) = NULL,
	@SndFirstName Varchar(50) = NULL,
	@SndLast1 Varchar(50) = NULL,                        
	@SndPhone Varchar(20) = NULL,             
	@SndState Varchar(40) = NULL,             
	@SndZip Varchar(15) = NULL,  
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
        
        IF @SndAddress IS NULL OR UPPER(LTRIM(RTRIM(@SndAddress))) = ''
        BEGIN
        	SET @ValidResult = 1
        	SET @ErrorCode = '11220'
			SET @FocusFieldName = 'Sender Address'
			RETURN	
        END
        
        IF @SndCity IS NULL OR UPPER(LTRIM(RTRIM(@SndCity))) = ''
        BEGIN
        	SET @ValidResult = 1
        	SET @ErrorCode = '11222' 
			SET @FocusFieldName = 'Sender City'
			RETURN	
        END
        
        IF @SndCountry IS NULL OR UPPER(LTRIM(RTRIM(@SndCountry))) = ''
        BEGIN
        	SET @ValidResult = 1
        	SET @ErrorCode = '1670' 
			SET @FocusFieldName = 'Sender Country'
			RETURN	
        END
        
        IF @SndFirstName IS NULL OR UPPER(LTRIM(RTRIM(@SndFirstName))) = ''
        BEGIN
        	SET @ValidResult = 1
        	SET @ErrorCode = '11217' 
			SET @FocusFieldName = 'Sender FirstName'
			RETURN	
        END
        
        IF @SndLast1 IS NULL OR UPPER(LTRIM(RTRIM(@SndLast1))) = ''
        BEGIN
        	SET @ValidResult = 1
        	SET @ErrorCode = '11218' 
			SET @FocusFieldName = 'Sender Last1'
			RETURN	
        END
        
        IF @SndPhone IS NULL OR UPPER(LTRIM(RTRIM(@SndPhone))) = ''
        BEGIN
        	SET @ValidResult = 1
        	SET @ErrorCode = '1011' 
			SET @FocusFieldName = 'Sender Phone'
			RETURN	
        END
        
        IF @SndState IS NULL OR UPPER(LTRIM(RTRIM(@SndState))) = ''
        BEGIN
        	SET @ValidResult = 1
        	SET @ErrorCode = '11221' 
			SET @FocusFieldName = 'Sender State'
			RETURN	
        END
        
        IF @SndZip IS NULL OR UPPER(LTRIM(RTRIM(@SndZip))) = ''
        BEGIN
        	SET @ValidResult = 1
        	SET @ErrorCode = '11223' 
			SET @FocusFieldName = 'Sender Zip'
			RETURN	
        END
		
    END TRY
    BEGIN CATCH
        SET @ValidResult = 1
    END CATCH
END
GO
