CREATE FUNCTION dbo.WebAgent_GetAvailabilityDateToShow
(@AvailabilityDate datetime,
@CurrentWebLanguageId INT)

RETURNS varchar(40)
AS
BEGIN
  DECLARE @StrAvailabilityDate varchar(40)

  DECLARE @Dow int
  DECLARE @M int

  SET @Dow = DATEPART(WEEKDAY,@AvailabilityDate)
  SET @m  = DATEPART(MONTH,@AvailabilityDate)
  IF @CurrentWebLanguageId =2
       BEGIN
	     IF @Dow = 1
		    SET @StrAvailabilityDate = 'Domingo, '
		 ELSE IF @Dow = 2
		    SET @StrAvailabilityDate = 'Lunes, '
		ELSE IF @Dow = 3
		    SET @StrAvailabilityDate = 'Martes, '
		ELSE IF @Dow = 4
		    SET @StrAvailabilityDate = 'Miércoles, '
		ELSE IF @Dow = 5
		    SET @StrAvailabilityDate = 'Jueves, '
		ELSE IF @Dow = 6
		    SET @StrAvailabilityDate = 'Viernes, '
		ELSE IF @Dow = 7
		    SET @StrAvailabilityDate = 'Sábado, '
		SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' '+convert(varchar,datepart(dd,@AvailabilityDate))
		IF @M = 1
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' de Enero '
		ELSE IF @M = 2
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' de Febrero '
		ELSE IF @M = 3
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' de Marzo '
		ELSE IF @M = 4
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' de Abril '
		ELSE IF @M = 5
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' de Mayo '
		ELSE IF @M = 6
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' de Junio '
		ELSE IF @M = 7
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' de Julio '
		ELSE IF @M = 8
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' de Agosto '
		ELSE IF @M = 9
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' de Septiembre '
		ELSE IF @M = 10
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' de Octubre '
		ELSE IF @M = 11
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' de Noviembre '
		ELSE IF @M = 12
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' de Diciembre '
		
		SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate) + ' de '+convert(varchar,datepart(yyyy,@AvailabilityDate))
		
	   END
  ELSE BEGIN
        IF @Dow = 1
		    SET @StrAvailabilityDate = 'Sunday, '
		ELSE IF @Dow = 2
		    SET @StrAvailabilityDate = 'Monday, '
		ELSE IF @Dow = 3
		    SET @StrAvailabilityDate = 'Tuesday, '
		ELSE IF @Dow = 4
		    SET @StrAvailabilityDate = 'Wednesday, '
		ELSE IF @Dow = 5
		    SET @StrAvailabilityDate = 'Thursday, '
		ELSE IF @Dow = 6
		    SET @StrAvailabilityDate = 'Friday, '
		ELSE IF @Dow = 7
		    SET @StrAvailabilityDate = 'Saturday, '
        IF @M = 1
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' January '
		ELSE IF @M = 2
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' February '
		ELSE IF @M = 3
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' March '
		ELSE IF @M = 4
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' April '
		ELSE IF @M = 5
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' May '
		ELSE IF @M = 6
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' June '
		ELSE IF @M = 7
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' July '
		ELSE IF @M = 8
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' August '
		ELSE IF @M = 9
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' September '
		ELSE IF @M = 10
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' October '
		ELSE IF @M = 11
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' November '
		ELSE IF @M = 12
		   SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' December '
		SET @StrAvailabilityDate = rtrim(@StrAvailabilityDate)+' '+convert(varchar,datepart(dd,@AvailabilityDate))+', '+convert(varchar,datepart(yyyy,@AvailabilityDate))
       END
 
      

  RETURN @StrAvailabilityDate
END