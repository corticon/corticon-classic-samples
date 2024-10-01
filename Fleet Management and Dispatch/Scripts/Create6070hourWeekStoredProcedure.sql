/****** Object:  StoredProcedure [dbo].[FlagHoursWorkedOverLimits]    Script Date: 10/1/2024 8:54:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FlagHoursWorkedOverLimits]
    @DriverId VARCHAR(255)
AS
BEGIN
    -- Temporary table to store the status changes for a given driver, excluding 'Off Duty'
    CREATE TABLE #DriverStatus (
        record INT,
        driverId VARCHAR(250),
        dutyStatus VARCHAR(250),
        durationMins INT,
        statusStart DATETIME,
        statusEnd DATETIME
    );

    -- Insert records where dutyStatus is not 'Off Duty'
    INSERT INTO #DriverStatus (record, driverId, dutyStatus, durationMins, statusStart, statusEnd)
    SELECT record, driverId, dutyStatus, durationMins, statusStart, statusEnd
    FROM DriverStatusChange
    WHERE driverId = @DriverId
      AND dutyStatus <> 'Off Duty';

    -- Temporary table to store flagged violations
    CREATE TABLE #FlaggedPeriods (
        PeriodType VARCHAR(50),
        StartDate DATETIME,
        EndDate DATETIME,
        TotalHoursWorked DECIMAL(5, 2)
    );

    -- Check for violations over any 7-day period (60 hours limit)
    INSERT INTO #FlaggedPeriods (PeriodType, StartDate, EndDate, TotalHoursWorked)
    SELECT '7 Day Period', MIN(statusStart), MAX(statusEnd),
           SUM(durationMins) / 60.0 AS TotalHoursWorked
    FROM #DriverStatus
    GROUP BY DATEDIFF(DAY, '1900-01-01', statusStart) / 7
    HAVING SUM(durationMins) > 60 * 60; -- More than 60 hours (3600 minutes)

    -- Check for violations over any 8-day period (70 hours limit)
    INSERT INTO #FlaggedPeriods (PeriodType, StartDate, EndDate, TotalHoursWorked)
    SELECT '8 Day Period', MIN(statusStart), MAX(statusEnd),
           SUM(durationMins) / 60.0 AS TotalHoursWorked
    FROM #DriverStatus
    GROUP BY DATEDIFF(DAY, '1900-01-01', statusStart) / 8
    HAVING SUM(durationMins) > 70 * 60; -- More than 70 hours (4200 minutes)

    -- Return the flagged violations
    SELECT * FROM #FlaggedPeriods;

    -- Cleanup temporary tables
    DROP TABLE #DriverStatus;
    DROP TABLE #FlaggedPeriods;
END;

GO

