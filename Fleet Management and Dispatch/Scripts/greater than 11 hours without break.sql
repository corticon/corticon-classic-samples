/****** Object:  StoredProcedure [dbo].[FlagDrivingOver11Hours]    Script Date: 10/1/2024 8:55:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FlagDrivingOver11Hours]
    @DriverId VARCHAR(255)
AS
BEGIN
    -- Select records where the dutyStatus is 'Driving' and the duration exceeds 11 hours (660 minutes)
    SELECT record, driverId, dutyStatus, durationMins, statusStart, statusEnd
    FROM DriverStatusChange
    WHERE driverId = @DriverId
      AND dutyStatus = 'Driving'
      AND durationMins > 660; -- 11 hours = 660 minutes
END;

GO

