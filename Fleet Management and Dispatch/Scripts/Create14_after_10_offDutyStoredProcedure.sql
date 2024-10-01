/****** Object:  StoredProcedure [dbo].[FlagDrivingViolations]    Script Date: 10/1/2024 8:58:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FlagDrivingViolations]
    @driverId VARCHAR(255)
AS
BEGIN
    -- Temporary table to store violations
    CREATE TABLE #Violations (
        driverId VARCHAR(255),
        record INT,
        statusStart DATETIME,
        statusEnd DATETIME,
        violationType VARCHAR(255)
    );
    
    -- Common Table Expression (CTE) to find the Off Duty periods of at least 10 hours for the given driver
    WITH OffDutyPeriods AS (
        SELECT 
            driverId,
            statusStart AS offDutyStart,
            statusEnd AS offDutyEnd,
            ROW_NUMBER() OVER (PARTITION BY driverId ORDER BY statusStart) AS rowNumber
        FROM DriverStatusChange
        WHERE driverId = @driverId  -- Filter by driverId
        AND dutyStatus = 'Off Duty'
        AND DATEDIFF(MINUTE, statusStart, statusEnd) >= 600  -- 10 hours * 60 minutes
    ),
    DrivingRecords AS (
        SELECT 
            dsc.driverId,
            dsc.record,
            dsc.statusStart,
            dsc.statusEnd,
            dsc.dutyStatus,
            ROW_NUMBER() OVER (PARTITION BY dsc.driverId ORDER BY dsc.statusStart) AS rowNumber
        FROM DriverStatusChange dsc
        WHERE dsc.driverId = @driverId  -- Filter by driverId
        AND dsc.dutyStatus = 'Driving'
    )
    SELECT 
        dsc.driverId,
        dsc.record,
        dsc.statusStart,
        dsc.statusEnd,
        CASE 
            WHEN DATEDIFF(HOUR, odp.offDutyEnd, dsc.statusStart) >= 14 THEN '14 Hour Driving Violation'
        END AS violationType
    INTO #TempViolations
    FROM DrivingRecords dsc
    CROSS APPLY (
        SELECT TOP 1 *
        FROM OffDutyPeriods odp
        WHERE odp.driverId = dsc.driverId
        AND odp.offDutyEnd < dsc.statusStart
        ORDER BY odp.offDutyEnd DESC
    ) odp
    WHERE DATEDIFF(HOUR, odp.offDutyEnd, dsc.statusStart) >= 14;

    -- Insert the violations into the Violations table
    INSERT INTO #Violations (driverId, record, statusStart, statusEnd, violationType)
    SELECT 
        driverId,
        record,
        statusStart,
        statusEnd,
        violationType
    FROM #TempViolations;

    -- Return the violations for the given driver
    SELECT * FROM #Violations;

    -- Clean up temporary tables
    DROP TABLE #TempViolations;
    DROP TABLE #Violations;
END;

GO

