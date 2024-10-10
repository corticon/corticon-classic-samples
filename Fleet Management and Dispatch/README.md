## Taming SQL Logical Complexities with a Business Rules Engine

For enterprises and government agencies whose operations depend on efficient logistical management of geographically diverse personnel and assets, capturing and acting on relevant data about these moving parts is critical. While the amount of data available and the sources from which this data is logged and exposed are more expansive than ever, the mounting complexity attributable to the continual accumulation of data from new and existing data sources necessitates thoroughly considered the extent to which the data can be acted upon, not accumulated just for the sake of it.

Business processes and decision-making for logistical functions like fleet management require data from enormous datasets, often spread across multiple databases and made available through different protocols, and maintained in distinct formats. Individual decisions that seem straightforward, answering simple questions with simple answers-- may rely upon a labyrinth of intermediate business logic and data operations executed along the way.

With the proliferation of connected technologies and the resulting growth in the scale and variability of data, ensuring that applications are able to access specifically relevant data—no more, no less— for a given business process is a critical performance and security requirement for organizations' enterprise architects.

Effective use of SQL helps minimize the processing time required to get to desired subsets of data, but this approach can quickly result in organizations unwittingly hoisting an anvil of maintainability issues over their operations. As regulations change, data sources expand, storage and compute costs grow, personnel turn over, and novel security threats appear, the practice of intertwining logic and data within the database using SQL tends to make it increasingly difficult to isolate bottlenecks.

![stack of files](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/9zzdy6j8jpwxdq5rq88j.jpg)

## Design Approaches for Data Driven Decisions

In this tutorial, I'll try to solve for some of the fleet management challenges which can present maintainability challenges, first by implementing a SQL only approach to common queries. Then, I'll show how those queries can be made more maintainable, traceable, and understandable by externalizing rules in a rules engine yet operating on the same SQL data source.

Fleet management encompasses the logistical tasks related to vehicle maintenance, driver dispatch and scheduling, cargo tracking and related services in managing moving people and parts. For example, a cable company's fleet of vehicles driven by field service technicians, or a delivery company providing a network of courier and package delivery services.

Organizations that have fleets to manage must compete by maximizing efficiencies across numerous different areas—vehicle reliability, driving behavior and safety, route optimization, and trip completion timelines—representing distinct yet interdependent data points to weigh and balance. Moreover, safety regulations define maximum shifts in which a driver can be driving without a break, minimum break periods, and related measures to mitigate fatigue related dangers. For example, in the United States, the Department of Transportation defines 'Hours of Service Rules' which [stipulate](https://www.fmcsa.dot.gov/regulations/hours-service/summary-hours-service-regulations) the limits such as:

* **14-hour shift limit** - When a driver comes off any ten hour period in which they were off duty, they can only drive in the time window between when they come on duty and 14 hours later (not that they would be driving for the entire 14 hours). After this 14 hour period, they may not drive again until after another 10 hour period spent off duty.
* **11-hour driving limit** - Within this 14 hour window, a driver cannot be be driving for more than 11 total hours.
* **60/70-hour limit** - If a driver works for a carrier that operates vehicles fewer than 7 days per week, no driver may drive for more than 60 hours within a period of 7 consecutive days.  If the carrier does operate vehicles every day of the week, then their drivers may not drive for more than 70 hours in any 8 consecutive day period
* **30-Minute Driving Break** - Drivers must take a 30-minute break when they have driven for a period of 8 cumulative hours without at least a 30-minute interruption.

Let's step through how these data points can be catalogued in a SQL database, and then how to assess these sorts of compliance queries directly within the database versus externalizing the query rule logic with business rules.

If you'd like to follow along, the instructions, scripts, and project files are all freely available in [this repository](https://github.com/corticon/corticon-classic-samples/tree/main/Fleet%20Management%20and%20Dispatch).

## Implementation Guide - Corticon Fleet Management

To follow along you'll need:

- **Progress Corticon Studio** - can be downloaded for free by following  [the &#39;download a trial&#39; link here](https://www.progress.com/corticon/get-started). The evaluation version of Corticon Studio support in full all functionalities described in this tutorial.
- **Microsoft SQL Server Management Studio (SSMS) 2019 Express** (other versions of SSMS are *likely* to work), which can be downloaded for free [here](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15). To ensure compatibility with Corticon's data integration drivers, please follow the installation configuration documented [here](https://docs.progress.com/bundle/corticon-edc-modeling-tutorial/page/Setting-up-the-tutorial.html).
- Download the template files from [here ](https://github.com/corticon/corticon-classic-samples/tree/main/Fleet%20Management%20and%20Dispatch)to create our database(s) and to import the pre-made rule project files.

## Create Fleet Manager Database

Let's start by creating the database and defining its schema.

Across various interrelated tables, we'll define some sample data about the entities involved with the fleet like Driver, Vehicle, Trip, and Destination. This can be automatically done by copying/downloading [this script](https://github.com/corticon/corticon-classic-samples/blob/main/Fleet%20Management%20and%20Dispatch/Scripts/CreateDataTableAndInsertDate.sql), opening it in Microsoft SQL Server Management Studio and clicking execute.

- Trip table: `dateOfArrival`, `dateOfDeparture`, `driverId`, `destinationID`, `originDepotID`
- Depot table: `depotID`, `streetAddress`, `city`, `state`
- Destination table: `destinationID`, `streetAddress`, `city`, `state`
- Driver table: `driverId`, `first`, `last`
- DriverStatusChange: `record`, `statusStart`, `statusEnd`, `dutyStatus`, `driverId`

You should see a message that the query was completed popup in the bottom of the interface. If you don't see the newly created database "CorticonFleetManager" in the Object Explorer on the left hand side of your SQL Studio window, right click the root element in the project explorer (likely has your computer's assigned name followed by "\SQLEXPRESS..."), and click refresh.

Expand out the database by clicking the '+' icon next to its name, and then expand the Tables folder to show the data tables.

If you right click one of the table names and click 'Select Top XYZ Rows', you'll see the initial set of dummy data we're going to use. This data is primarily generated using [Mockaroo](https://mockaroo.com/), but was also supplemented by using Corticon itself to generate data!

## Querying for Driving Compliance Violations with SQL

Let's now create some queries which will enable us to answer questions about the data.

### SQL View of Trip Origins and Destinations

To start, take a look at the data in the `Trip` table of the database. You'll see that we have information about the trip's origin depot and the destination, but not the location information in full--only identifiers for `destinationID` and `originDepotID`.

To view the location information for the trip's start and end points, we could create a [view](https://learn.microsoft.com/en-us/sql/relational-databases/views/views?view=sql-server-ver16) that presents each trip in a row that combines the `Origin` and `Destination` location data for each `Trip`, using the identifiers denoted in the Trip table. To create this view, execute [this SQL](https://github.com/corticon/corticon-classic-samples/blob/main/Fleet%20Management%20and%20Dispatch/Scripts/TripDetails.sql) in a new query window.

If successful, you should see the text in the 'Messages' pane that "Commands completed successfully."

Now, we can get the data we're after using a query like

```sql
SELECT [tripID]
	,[originStreetAddress]
	,[originCity]
	,[originState]
	,[destinationStreetAddress]	  
	,[destinationCity]
	,[destinationState]
  FROM [CorticonFleetManager].[dbo].[TripDetails]
  WHERE tripID=1999323
```

Which would output:

| tripID  | originStreetAddress | originCity | originState   | destinationStreetAddress | destinationCity | destinationState |
| ------- | ------------------- | ---------- | ------------- | ------------------------ | --------------- | ---------------- |
| 1999323 | 04 Dexter Terrace   | Worcester  | Massachusetts | 85 Hagan Plaza           | Manchester      | New Hampshire    |

Not too painful, but this hasn't solved many problems for our fleet company. More realistically, we might have the company compliance officer request a report that will help them track and document driving shifts to demonstrate compliance with the HOS rules.

### SQL Table Valued Function of Trip Origins, Destinations, and Driver Info

* A first step could be to pull in data about the driver for each of these trips. This could be create with a [table-valued function](https://learn.microsoft.com/en-us/sql/relational-databases/user-defined-functions/create-user-defined-functions-database-engine?view=sql-server-ver16#TVF), an alternative approach for selecting and displaying related data from various tables joined by a defined set of key criteria. To create this function, you can run [this script](https://github.com/corticon/corticon-classic-samples/blob/main/Fleet%20Management%20and%20Dispatch/Scripts/GetTripDetailsWithDriverInfo.sql) in a new query window.
* Once created, we run queries like the following in order to see the driver details for the respective trips:

```sql
SELECT * FROM [dbo].[GetTripDetailsWithDriverInfo] ()
GO
```

The top few results we get back should look something like this:

| tripID  | originCity  | originState   | originStreetAddress | destinationCity | destinationState | destinationStreetAddress | driverFirstName | driverLastName | driverEmail                | driverPhone  |
| ------- | ----------- | ------------- | ------------------- | --------------- | ---------------- | ------------------------ | --------------- | -------------- | -------------------------- | ------------ |
| 1999323 | Worcester   | Massachusetts | 04 Dexter Terrace   | Manchester      | New Hampshire    | 85 Hagan Plaza           | Vivyanne        | Denizet        | vdenizet7@csmonitor.com    | 598-283-8892 |
| 2105883 | Lynn        | Massachusetts | 7556 Fremont Hill   | Boston          | Massachusetts    | 9562 Roth Circle         | Elvina          | Paddison       | epaddison8@wordpress.org   | 371-456-5406 |
| 2142826 | Springfield | Massachusetts | 914 Heffernan Plaza | Waltham         | Massachusetts    | 567 Carberry Center      | Salomi          | Sammonds       | ssammondst@fastcompany.com | 805-578-1666 |
| 2148980 | Lynn        | Massachusetts | 7556 Fremont Hill   | Waltham         | Massachusetts    | 84398 Vermont Circle     | Carol-jean      | Collick        | ccollickg@ocn.ne.jp        | 173-318-5651 |
| 2380224 | Manchester  | New Hampshire | 5657 Nova Park      | Boston          | Massachusetts    | 1284 Basil Road          | Lucais          | Rickardsson    | lrickardssonb@etsy.com     | 435-394-7326 |
| 4214048 | Waltham     | Massachusetts | 37767 Bartelt Place | Boston          | Massachusetts    | 81 Caliangt Pass         | Reagen          | Roglieri       | rroglierii@sbwire.com      | 752-814-7885 |
| 4324638 | Manchester  | New Hampshire | 5657 Nova Park      | Worcester       | Massachusetts    | 56 New Castle Lane       | Elvina          | Paddison       | epaddison8@wordpress.org   | 371-456-5406 |
| 4787172 | Waltham     | Massachusetts | 37767 Bartelt Place | Boston          | Massachusetts    | 997 Schlimgen Park       | Wendell         | Clatter        | Wendellc@gmail.com         | 752-814-8723 |
| 6738436 | Lynn        | Massachusetts | 7556 Fremont Hill   | Portland        | Maine            | 9 Prairie Rose Trail     | Jae             | Liddon         | jliddonq@photobucket.com   | 936-348-8823 |
| 7029025 | Manchester  | New Hampshire | 5657 Nova Park      | Montpelier      | Vermont          | 017 Waubesa Place        | Desirae         | Bawdon         | dbawdon9@live.com          | 430-153-9555 |
| 7240845 | Manchester  | New Hampshire | 21087 Haas Lane     | Brockton        | Massachusetts    | 0 Emmet Trail            | Stan            | Foran          | sforanj@ucoz.com           | 538-784-6972 |
| 7969721 | Manchester  | New Hampshire | 21087 Haas Lane     | Portsmouth      | New Hampshire    | 1 Bayside Center         | Adela           | O'Hederscoll   | aohederscolll@redcross.org | 738-350-1113 |
| 8648078 | Manchester  | New Hampshire | 5657 Nova Park      | Portsmouth      | New Hampshire    | 68506 Moland Center      | Carol-jean      | Collick        | ccollickg@ocn.ne.jp        | 173-318-5651 |
| 8789396 | Waltham     | Massachusetts | 37767 Bartelt Place | Springfield     | Massachusetts    | 014 Orin Road            | Cassie          | Docker         | cdocker4@blogspot.com      | 189-509-8433 |

We're one step closer to documenting the drivers' hours of service regulatory information, but now we'll need to really get creative to get information about the various legs of each trip, in order to verify whether the driving shifts exceeded any of the defined thresholds, such as driving 11 hours in a 14 hour period.

### SQL Stored Procedure of Driving Shifts

We're presented with a few challenges to accomplish this, as data is spread across a quite distributed database schema. Drivers' vehicles in an organization's fleet generally will have an Electronic Logging Device (ELD) onboard to log and report on the vehicle's statuses. From these ELD devices, fleet managers must maintain drivers' hours of duty records for compliance purposes, capturing data required by regulators in the format required by regulators.

In the database we're working with, the ELD records are stored in the `DriverStatusChange` table. Each driver change in shift records the new status as one of: "Drive", "On Duty", "Sleeper Berth", and "Off-duty". For the rules related to driving time between off duty periods, we must:

1. Segment out the records chronologically into groupings separated by any row where, in the `DriverStateChange` table, the row `dutyStatus`='Off Duty' and the duration is greater than 10 hours based upon the `statusStart `and `statusEnd `rows
2. From within each of these groupings, sum together the duration of all rows where `dutyStatus`='Driving'. If this value is greater than 11, then this represents a violation of **rule 1: drivers may not drive more than 11 hours after 10 consecutive hours off duty.**
3. From within each of these groupings between 10 hours off duty, identify any case where the driver had a status of 'Driving' beyond the 14th hour after they had come back on duty. These will represent violations of **rule 2: drivers may not drive beyond the 14th consecutive hour after coming on duty, following 10 consecutive hours off duty**

#### Rule 1: 11 hours after 10 consecutive hours off duty

*May drive a maximum of 11 hours after 10 consecutive hours off duty.*

* Rule 1 is fairly straightforward to create a stored procedure for. For a given `driver` identified by their `driverID` in the `DriverStatusChange` table, flag any instance of a row where the `DriverStatusChange` `dutyStatus` field = 'Driving' and the `durationMins` > 660 (11 hours).

```
CREATE PROCEDURE [dbo].[FlagDrivingOver11Hours]
    @DriverId VARCHAR(255)
AS
BEGIN
    SELECT record, driverId, dutyStatus, durationMins, statusStart, statusEnd
    FROM DriverStatusChange
    WHERE driverId = @DriverId
      AND dutyStatus = 'Driving'
      AND durationMins > 660; 
END;
GO
```

* When we execute the procedure for any of the Drivers' `driverId` values such as

```
DECLARE	@return_value int
EXEC	@return_value = [dbo].[FlagDrivingOver11Hours]
DriverId = N'271177229'
```

| record | driverId  | dutyStatus | durationMins | statusStart             | statusEnd               |
| ------ | --------- | ---------- | ------------ | ----------------------- | ----------------------- |
| 1126   | 271177229 | Driving    | 668          | 2024-01-15 17:10:38.000 | 2024-01-16 04:18:38.000 |
| 1366   | 271177229 | Driving    | 679          | 2024-01-19 09:58:46.000 | 2024-01-19 21:17:46.000 |
| 2846   | 271177229 | Driving    | 698          | 2024-02-09 16:45:36.000 | 2024-02-10 04:23:36.000 |

#### Rule 2: Driving beyond 14th hour

*May not drive beyond the 14th consecutive hour after coming on duty, following 10 consecutive hours off duty. Off-duty time does not extend the 14-hour period.*

Now we're getting into more tricky territory. For this procedure, an approach could be to:

* Create a temporary table which will hold the statuses flagged as violating the rule.

```
CREATE PROCEDURE [dbo].[FlagDrivingViolations]
    @driverId VARCHAR(255)
AS
BEGIN
    CREATE TABLE #Violations (
        driverId VARCHAR(255),
        record INT,
        statusStart DATETIME,
        statusEnd DATETIME,
        violationType VARCHAR(255)
    );
```

* Use a common table expression to find all Off Duty statuses with a duration over 10 hours for the `Driver`, along with all Driving statuses with their status start/stop times.

```
WITH OffDutyPeriods AS (
        SELECT 
            driverId,
            statusStart AS offDutyStart,
            statusEnd AS offDutyEnd,
            ROW_NUMBER() OVER (PARTITION BY driverId ORDER BY statusStart) AS rowNumber
        FROM DriverStatusChange
        WHERE driverId = @driverId  
        AND dutyStatus = 'Off Duty'
        AND DATEDIFF(MINUTE, statusStart, statusEnd) >= 600  
    DrivingRecords AS (
        SELECT 
            dsc.driverId,
            dsc.record,
            dsc.statusStart,
            dsc.statusEnd,
            dsc.dutyStatus,
            ROW_NUMBER() OVER (PARTITION BY dsc.driverId ORDER BY dsc.statusStart) AS rowNumber
        FROM DriverStatusChange dsc
        WHERE dsc.driverId = @driverId 
        AND dsc.dutyStatus = 'Driving'
    )
```

* From these results, select any instances with a duty stauts of 'Driving' beyond 14 hours since 10 hours spent off duty.

```
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

```

* Insert these records into the temporary table and clean up the temporary tables.

```
    INSERT INTO #Violations (driverId, record, statusStart, statusEnd, violationType)
    SELECT
        driverId,
        record,
        statusStart,
        statusEnd,
        violationType
    FROM #TempViolations;  
    SELECT * FROM #Violations;  
    DROP TABLE #TempViolations;
    DROP TABLE #Violations;
END;
```

* By calling the procedure from with a driverID, we can see the  `EXEC FlagDrivingViolations @driverId = '202251400';`

| driverId  | record | statusStart              |        statusEnd         | violationType             |
| --------- | ------ | ------------------------ | :----------------------: | ------------------------- |
| 202251400 | 594    | 2024-01-07T06:09:19.000Z | 2024-01-07T11:24:19.000Z | 14 Hour Driving Violation |

#### Rule 3: 60/70-Hour Driving Limit

*May not drive after 60/70 hours on duty in 7/8 consecutive days. A driver may restart a 7/8 consecutive day period after taking 34 or more consecutive hours off duty.*

This is complex! There are a considerable number of 'ifs' to evaluate here. We will need to evaluate the 7 day periods and 8 day periods subsequent to every instance that a `DriverStatusChange.dutyStatus`, in order to sum together the hours not 'Off Duty' over that period. Over the 8 day stretch, the sum of the status durations not 'Off Duty' cannot exceed 70 hours, and for the 7 day stretch, 60 hours. But if there exists any instance in that window where the `Driver` has a `DriverStatusChange` record of `dutyStatus`='Off Duty' with a `durationHours`>=34, then skip over that calculation.

* Here we might use a procedure that first creates a temporary table to hold all statuses that are not 'Off Duty'.

```
CREATE PROCEDURE [dbo].[FlagHoursWorkedOverLimits]
    @DriverId VARCHAR(255)
AS
CREATE TABLE #DriverStatus (
        record INT,
        driverId VARCHAR(250),
        dutyStatus VARCHAR(250),
        durationMins INT,
        statusStart DATETIME,
        statusEnd DATETIME
    );
    INSERT INTO #DriverStatus (record, driverId, dutyStatus, durationMins, statusStart, statusEnd)
    SELECT record, driverId, dutyStatus, durationMins, statusStart, statusEnd
    FROM DriverStatusChange
    WHERE driverId = @DriverId
    AND dutyStatus <> 'Off Duty';
```

* And a temporary table to hold all flagged violations:

```
    CREATE TABLE #FlaggedPeriods (
        PeriodType VARCHAR(50),
        StartDate DATETIME,
        EndDate DATETIME,
        TotalHoursWorked DECIMAL(5, 2)
    );  
    INSERT INTO #FlaggedPeriods (PeriodType, StartDate, EndDate, TotalHoursWorked)
    SELECT '7 Day Period', MIN(statusStart), MAX(statusEnd),
           SUM(durationMins) / 60.0 AS TotalHoursWorked
    FROM #DriverStatus
    GROUP BY DATEDIFF(DAY, '1900-01-01', statusStart) / 7
    HAVING SUM(durationMins) > 60 * 60;
    INSERT INTO #FlaggedPeriods (PeriodType, StartDate, EndDate, TotalHoursWorked)
    SELECT '8 Day Period', MIN(statusStart), MAX(statusEnd),
           SUM(durationMins) / 60.0 AS TotalHoursWorked
    FROM #DriverStatus
    GROUP BY DATEDIFF(DAY, '1900-01-01', statusStart) / 8
    HAVING SUM(durationMins) > 70 * 60;
    SELECT * FROM #FlaggedPeriods;  
    DROP TABLE #DriverStatus;
    DROP TABLE #FlaggedPeriods;
END;
```

* And finally call the procedure with a driverID:

```
DECLARE	@return_value int
EXEC	@return_value = [dbo].[FlagHoursWorkedOverLimits]
		@DriverId = N'202251400'
GO
```

| PeriodType   | TotalHoursWorked | StartDate               | EndDate                 |
| ------------ | ---------------- | ----------------------- | ----------------------- |
| 7 Day Period | 75.08            | 2024-01-01 02:00:00.000 | 2024-01-07 22:30:21.000 |
| 7 Day Period | 69.10            | 2024-01-08 06:43:23.000 | 2024-01-15 00:58:10.000 |
| 7 Day Period | 76.23            | 2024-01-15 03:31:12.000 | 2024-01-21 19:55:58.000 |
| 7 Day Period | 72.40            | 2024-01-22 03:00:00.000 | 2024-01-29 04:16:44.000 |
| 8 Day Period | 77.77            | 2024-01-07 04:17:18.000 | 2024-01-15 00:58:10.000 |
| 8 Day Period | 86.23            | 2024-01-15 03:31:12.000 | 2024-01-22 23:26:06.000 |
| 8 Day Period | 73.65            | 2024-01-23 07:03:08.000 | 2024-01-30 20:05:54.000 |

That's a lot-- and we didn't even check for the 34 hour exclusion rule. Also, what about any overlapping periods that violate the rule?

Let's shift to Corticon to see how we can solve the above and more.

## Querying for Driving Compliance Violations with Corticon + SQL

### How Corticon modularizes querying, data, and rules

In Corticon, the _rule vocabulary_ provides a singular dictionary of business terminologies that will serve as building blocks to build decisions from--elements in the vocabulary are abstractions of all data involved in the decision. For example, an application may pass some data about a driver to a Corticon decision service that conforms to the model of the rule vocabulary, and that decisions service may retrieve/overwrite/delete elements of that vocabulary over the course of rule evaluation or by accessing external data sets.

Corticon rule vocabularies can be *mapped*  to data in any of the leading relational databases as well as to REST APIs. For this Corticon project, we'll make use of Corticon's Advanced Data Connector (ADC), to trigger queries to be performed during the execution of a decision service.

This allows rule architects to optimize decision processing efficiency by retrieving data at specific points in the execution of a decision service, with queries populated by either data sent in the initial input to the decision service, or data produced in preceding rulesheets in a ruleflow. Planning how to use data queries as part of a decision service execution is an essential way to minimize the '[chattiness](https://www.mushroomnetworks.com/blog/called-chatty-application/)' symptomatic in data-intensive decisioning.

### How the rules and queries are organized

Similar to the way stored procedures and views are kept separate from the data tables in a database, but preconfigured to be run against the actual data set we're interested in, we separate out the queries and the data when using ADC:

1. **CorticonFleetManager Database** - the same database as used in the exercises above, containing tables like `Driver`, `Trip`, `Destination`, and `DriverStatusChange`.
2. **fleetQueries Database** - Serves as the library of preconfigured, parameterized queries to be executed during a decision service.
   * `CORTICON_ADC_READ `- Table containing rows of each *read* query's name and unique ID
   * `CORTICON_ADC_READ_DEFS `- Table containing one or more rows per read query ID, the sequence in which they should be executed, and the Corticon rule vocabulary entity / entities that are mapped to the data being retrieved

In Corticon Studio, the vocabulary is mapped to the CorticonFleetManager database tables, and the fleetQueries are imported and then usable in a Ruleflow. This ruleflow, made up of rule logic and these queries, can then be generated into a decision service as illustrated below.

<img src="https://smeldon.sirv.com/Presentation1.gif" width="2297" height="1263" alt="">

### Generate the Rule Vocabulary from the Fleet Management Database Schema

For our fleet management scenario that starts from a database containing the fleet company's data, we'll start by generating a vocabulary from the schema of the CorticonFleetManager database. this way, the schema is automatically incorporated into the rule vocabulary's structure with the entities' interrelations.

<img src="https://smeldon.sirv.com/S1gqz.gif" width="2297" height="1263" alt="">

### Connect to the Query Database

In either the same database or an entirely separate database, we'll next define the queries to evaluate rules based upon this data. These queries are essentially parameterized SQL that substitutes variables specified 'upstream' in the rules.

![queries](https://i.ibb.co/3Cs99zN/queries.png)

Similar to the ADC datasource, we'll connect to the query database, but the data contained within the database is not data involved with the business decision--rather, this database will contain the queries that will be referenced by Corticon during rule processing. These queries then can be executed at specified points in a single decision service's execution, in order to fulfill workflows like the following:

1. **Query 1:** For the provided DriverID, retrieve the applicable record from the `Driver` table in the CorticonFleetManager database, and map the `Driver` data to the Driver entity in the Corticon vocabulary. Then pull in all `DriverStatusChange` records with this same `DriverID`, and associate these `DriverStatusChange` records in the Corticon vocabulary as child entities to the `Driver`.
2. **Query 2:**  Based upon the driver type specified in the `Driver` table, retrieve regulatory thresholds from the Thresholds table. Here, we'll externalize the values for thresholds like maximum hours a driver can legally drive consecutively. These can then be referenced in subsequent rulesheets to flag non-compliant shifts.
3. **Business Rules:** Identify violations for a given driver of the 60/70 hours in 7/8 days rule, driving after the 14th hour on duty rule, and driving more than 11 hours without a break.

![ruleflow](https://i.ibb.co/Sfxncnj/ruleflow.png "ruleflow")

## The Business Rules

### Rulesheet - Initialize Values

After the two ADC READ operations are executed, the ruleflow subsequently executes the 'Initialize Values' rulesheet. This rulesheet:

* Solves `DriverStatusChange.durationHours` based on `DriverStatusChange.durationMinutes`/60
* Sets `Driver.offDutyCount` to be the size of the collection of `Driver.driverStatusChange` where `dutyStatus` = 'Off Duty'
* Sets a placeholder value of '1' for the attribute `Driver.temp`. This will be used as a counter for looping during subsequent rulesheets.

![initialize rulesheet](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ij3yc1q2tpraad8mz7ph.png)

### Ruleflow: 60 70 Hour Limit

![60 70 hour limit ruleflow](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/uhalrniped8l5jc0xzmk.png)

#### Iterative Rulesheet - Create Work Periods

This rulesheet iterates until no more changes occur when evaluated. We create a new entity, `Period` associated as a child to `Driver`, which will contain the attributes `day1`, `day7`, and `day8`. We iterate over this rulesheet to create unique instances of `Period` for the 8 days subsequent to every `DriverStatusChange`. Each `Period` will contain the date of the `DriverStatusChange` in the attribute `day1`, add 6 to that value for the attribute `day7`, and add 7 to that value for the attribute `day8` until the number of periods=the number of statuses.

![create work periods](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/rk7cq9b2bhhwtwen1nzr.png)

#### Ruleflow: 8 Day Rules

![8 day](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/p278l2pvueaha7987pt5.png)

##### Rulesheet 1 - Associate statuses with 8 day period

Add any instance of `Driver.driverStatusChange` to the collection `Driver.period.driverStatusChange` for any `driverStatusChange` where :

* `Driver.driverStatusChange` attribute `dutyStatus` is 'Off Duty' as well as has a `durationHours` >= 34
* The ` Driver.driverStatusChange` `statusStart` and `statusEnd` are within a period's `day1` and `day8`values.

![associate statuses 8](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/foagymy90aivp0209zbk.png)

##### Rulesheet 2 - Sum statuses 8 days

Set the value of `Driver.period.hoursNotOffDuty8` to be the sum of all `DriverStatusChange.durationHours` where `DriverStatusChange` is a child entity of `Driver.period`.

![sum statuses 8](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/vy82dijgzrleyrns5gjf.png)

#### Ruleflow: 7 Day Rules

![7 day](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/omd1gavqh0ub2mjcotxj.png)

##### Rulesheet 1 - Remove association

Removes the previously created association between `DriverStatusChange` and `Period` created in the 8 day ruleflow.

![7 remove associations](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/8zq86uptarhxnxx3003t.png)

##### Rulesheet 2 - Associate statuses with 7 day period

Add any instance of `Driver.driverStatusChange` to the collection `Driver.period.driverStatusChange` for any `DriverStatusChange` where :

* `Driver.driverStatusChange` attribute `dutyStatus` is 'Off Duty' as well as has a `durationHours `>= 34
* The `Driver.driverStatusChange` `statusStart` and `statusEnd` are within a period's `day1 `and `day7 `values.

![associate statuses 7](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/te5sfpza08l604wgqimv.png)

##### Rulesheet 3 - Sum statuses 7 days

Set the value of `Driver.period.hoursNotOffDuty7` to be the sum of all `DriverStatusChange.durationHours` where `DriverStatusChange `is a child entity of `Driver.period.`

![sum statuses 7](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/vp4kb8tjlzxdox04ruco.png)

#### Rulesheet - Overtime Flags

For any instance of `Driver.period` where `hoursNotOffDuty7` > 60, create a new instance of `HOS_Flag` as a child entity to `Driver`, with the attribute `type` having a value of '>60 hours in 7 days' and the attribute `when` having a value of [`Period.day1`] to [`Period.day7`], time not off duty was [`Driver.period.hoursNotOffDuty7`].

For any instance of `Driver.period` where `hoursNotOffDuty8` > 70, create a new instance of `HOS_Flag` as a child entity to `Driver`, with the attribute `type` having a value of '>70 hours in 8 days' and the attribute `when` having a value of [`Period.day1`] to [`Period.day8`], time not off duty was [`Driver.period.hoursNotOffDuty8`].

![ot flags](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/6ti8wau7yobx0h2ys20g.png)

### Ruleflow: Time Driving per Shift Rules

![time driving per shift rules](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/2llget8v1s5555j46383.png)

#### Iterative Rulesheet: Create Windows Off Duty

This rulesheet iterates until no more changes occur when evaluated. We create a new entity, `ShiftWindow` associated as a child to `Driver`, which will contain the attribute `statusEnd`, `statusStart`, `isOffDuty`, and `windowID`. Corticon will iterate over this rulesheet to create a new `ShiftWindow` for every instance of `DriverStatusChange` where `dutyStatus` = 'Off Duty'.

The rulesheet will set the `windowID `for each `ShiftWindow` to be the value of `Driver.temp`, while `Driver.temp` will be incremented up by 1 each time the rulesheet executes, repeating until the value of the `Driver.temp` is equal to the number of off duty statuses.

![create windows off duty](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qt47t51q5caso8rozeiu.png)

#### Rulesheet: Reset

Set `Driver.temp` back to 1.

![reset](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/i6ei6qxd7jywbxjjpewy.png)

#### Iterative Rulesheet: Create Windows Driving

Here we're creating three aliases for `Driver.drivingWindow `- 'preceding', 'subsequent', and 'timeNotOff':

* 'preceding' - represents any case where `Driver.drivingWindow`.`windowID `= `Driver.temp` and `isOffDuty` = `T`
* 'subsequent' - represents any case where `Driver.drivingWindow`.`windowID `= `Driver.temp+1` and `isOffDuty` = `T`
* 'timeNotOff' - this will represent the period of time in between the times off duty

This rulesheet will iteratively create new, unique `ShiftWindow` entities under the timeNotOff alias, until there are no further instances of the 'subsequent' alias to evaluate.

![create windows driving](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/7f2vtg4o8mu7mydhdm9j.png)

#### Rulesheet: Group Windows

Similar to the design pattern with the 60/70 hour rules, here we're going to set `DriverStatusChange` to be a child entity to any instance of `ShiftWindow` within the same `statusStart` and `statusEnd` times, where the value of `DriverStatusChange.dutyStatus`='Driving'.

![group windows](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/5wqrnebdfv8h0kcza4hz.png)

#### Rulesheet: Duration Driving Between off Duty Windows

Evaluate all instances of the newly associated `DriverStatusChange` entities that are a child of `DrivingWindow` for the driver. If the last instance of `Driver.drivingWindow.driverStatusChange` any each `Driver.drivingWindow `has a  driving  `statusEnd `greater than 14 hours after the `drivingWindow`, create a new `HOS_flag` with the value for the attribute `when` set to ='Last off duty concluded at [`Driver.shiftWindow.statusStart`], driving status ended at [`Driver.drivingWindow.driverStatusChange.statusEnd`] and for the attribute `type` set to='Driving status ended more than 14 hours since off duty'.

![duration between windows](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/pxhrkah2irav7vfpawfi.png)

#### Rulesheet: 11 in 14 flags

Evaluate all instances of the newly associated `DriverStatusChange` entities that are a child of `DrivingWindow` for the driver. If any instance of `Driver.drivingWindow` has a `durationHours` spent with a duty status of 'Driving' greater than the 11 permissible hours they may drive in a 14 hour window, create a new `HOS_flag` with with the value of the `when `attribute set to ='Driving shift of [`DriverStatusChange.durationHours`] beginning [`DriverStatusChange.statusStart`]' and the `type` attribute set to '>11 hour driving within 14 hour period on duty'.

![11 in 14](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/t23bfs4n7ssvuj378lyk.png)

### Rulesheet: remove temporary fields

Remove the newly created entities (`Period`, `ShiftWindow`) as well as the retrieved and `DriverStatusChange` records from the final response payload of the decision services.

![remove temp](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ddwa1hw1j0nzihrmka4m.png)

## Better Together

Our ruleflow can now be generated into a decision service on Corticon Server, turning our compliance assessment into a ready to use API endpoint for decisioning. These rules could be built upon or add in a write step, to persist the final determinations back to the database.

We could also run this decision as a regular batch job, evaluating many records concurrently across disparate data sources and persisting the outputs directly back into a database.

By externalizing the logic which evaluates driving compliance from the underlying data that the logic is evaluating, business analysts at logistics-intensive companies maintain rules without needing to know all of the complexities of the ever-changing fleet data. Because we can incorporate any number of data sources, we can maintain the regulatory thresholds separate from the logic which pulls in the relevant records, keeping distinct areas of the decision in quickly adaptable modules.

And, we can build in further functionalities that would be very difficult to maintain through other approaches, such as incorporating data from REST API endpoints like geocoding and weather condition APIs, in order to ensure all variables beyond just regulatory considerations are readily available and maintainable in a fleet manager's dispatch application.

With Corticon, existing application logic doesn't need to be eliminated, and new experts in complex languages don't need to be brought in. Instead Corticon enables enterprises to separate the 'know' from the 'flow' of their complex decision making logic, future proofing the systems from which major competitive differentiators can be derived.

By leveraging an organization's existing in house skill sets like familiarity with writing SQL, IT stakeholders can create reusable queries to pull in data where and when necessary during the execution of business decisions, while rule authors remain tasked with the authoring and optimization of codeless business rules that define how to evaluate inputted/retrieved data.
