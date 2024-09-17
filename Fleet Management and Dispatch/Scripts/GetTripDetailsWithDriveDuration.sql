/****** Object:  StoredProcedure [dbo].[GetTripDetailsWithDriveDuration]    Script Date: 9/16/2024 9:40:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetTripDetailsWithDriveDuration]
AS
BEGIN
    -- Create a temporary table to store intermediate results
    CREATE TABLE #TripDetails (
        tripID BIGINT,
        originCity VARCHAR(255),
        originState VARCHAR(255),
        originStreetAddress VARCHAR(255),
        destinationCity VARCHAR(255),
        destinationState VARCHAR(255),
        destinationStreetAddress VARCHAR(255),
        driverFirstName VARCHAR(255),
        driverLastName VARCHAR(255),
        driverId VARCHAR(255),
        tripStartTime DATETIME2(7),
        tripEndTime DATETIME2(7),
        tripDurationMinutes FLOAT,
        driveDurationMinutes FLOAT
    );

    -- Insert data into the temporary table
    INSERT INTO #TripDetails (tripID, originCity, originState, originStreetAddress, 
                              destinationCity, destinationState, destinationStreetAddress,
                              driverFirstName, driverLastName, driverId,
                              tripStartTime, tripEndTime, tripDurationMinutes, driveDurationMinutes)
    SELECT 
        t.tripID,
        o.city AS originCity,
        o.state AS originState,
        o.streetAddress AS originStreetAddress,
        d.city AS destinationCity,
        d.state AS destinationState,
        d.streetAddress AS destinationStreetAddress,
        dr.first AS driverFirstName,
        dr.last AS driverLastName,
        dr.driverId AS driverId,
        t.dateOfDepature AS tripStartTime,
        t.dateOfArrival AS tripEndTime,
        DATEDIFF(MINUTE, t.dateOfDepature, t.dateOfArrival) AS tripDurationMinutes,
        COALESCE(SUM(DATEDIFF(MINUTE, ds.statusStart, ds.statusEnd)), 0) AS driveDurationMinutes
    FROM 
        dbo.Trip t
    LEFT JOIN 
        dbo.Depot o ON t.originDepotID = o.depotID
    LEFT JOIN 
        dbo.Destination d ON t.destinationID = d.destinationID
    LEFT JOIN 
        dbo.Driver dr ON t.driverId = dr.driverId
    LEFT JOIN 
        dbo.DriverStatusChange ds ON ds.driverId = dr.driverId
        AND ds.dutyStatus = 'Drive'
        AND ds.statusStart >= t.dateOfDepature
        AND ds.statusEnd <= t.dateOfArrival
    GROUP BY
        t.tripID,
        o.city,
        o.state,
        o.streetAddress,
        d.city,
        d.state,
        d.streetAddress,
        dr.first,
        dr.last,
        dr.driverId,
        t.dateOfDepature,
        t.dateOfArrival;

    -- Select the results from the temporary table
    SELECT * FROM #TripDetails;

    -- Drop the temporary table
    DROP TABLE #TripDetails;
END;

GO

