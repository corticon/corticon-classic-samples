/****** Object:  UserDefinedFunction [dbo].[GetTripDetailsWithDriverInfo]    Script Date: 9/16/2024 9:37:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetTripDetailsWithDriverInfo]()
RETURNS TABLE
AS
RETURN
(
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
        dr.email AS driverEmail,
        dr.phone AS driverPhone
    FROM 
        dbo.Trip t
    LEFT JOIN 
        dbo.Depot o ON t.originDepotID = o.depotID
    LEFT JOIN 
        dbo.Destination d ON t.destinationID = d.destinationID
    LEFT JOIN 
        dbo.Driver dr ON t.driverId = dr.driverId
);

GO

