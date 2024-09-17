/****** Object:  View [dbo].[TripDetails]    Script Date: 9/16/2024 9:38:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TripDetails] AS
SELECT 
    t.tripID,
    o.city AS originCity,
    o.state AS originState,
    o.streetAddress AS originStreetAddress,
    d.city AS destinationCity,
    d.state AS destinationState,
    d.streetAddress AS destinationStreetAddress
FROM 
    dbo.Trip t
LEFT JOIN 
    dbo.Depot o ON t.originDepotID = o.depotID
LEFT JOIN 
    dbo.Destination d ON t.destinationID = d.destinationID;

GO

