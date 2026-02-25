--- TASK 1 ---

-- task 1.1: create tables
CREATE TABLE Hotel (
HotelKey INT IDENTITY(1,1) PRIMARY KEY,
HotelName VARCHAR(10),
City VARCHAR(100),
HotelDescription TEXT
);

CREATE TABLE HotelRoom (
RoomKey INT IDENTITY(1,1) PRIMARY KEY,
HotelKey INT FOREIGN KEY REFERENCES Hotel(HotelKey),
NumberOfGuests INT,
CostOfANight MONEY
);

CREATE TABLE Reservation (
ReservationKey INT IDENTITY(1,1) PRIMARY KEY,
RoomKey INT FOREIGN KEY REFERENCES HotelRoom(RoomKey),
DateFrom DATE,
DateTo DATE,
TotalCost MONEY
);

-- task 1.2 add new column
ALTER TABLE HotelRoom ADD isReserved BIT DEFAULT 0;

-- task 1.3 extend column length
ALTER TABLE Hotel
ALTER COLUMN HotelName VARCHAR(100);

-- task 1.4 insert 2+ rows into Hotel, 4+ into HotelRoom and 4+ rows into Reservation
INSERT INTO Hotel (HotelName, City, HotelDescription)
VALUES ('Hilton', 'Warsaw', 'Located at city center'),
       ('Rixos', 'Krakow', 'New hotel');

INSERT INTO HotelRoom (HotelKey, NumberOfGuests, CostOfANight, IsReserved)
VALUES (1, 2, 100, 0),
       (2, 1, 70, 1),
       (1, 3, 200, 1),
       (2, 1, 90, 0);

INSERT INTO Reservation (RoomKey, DateFrom, DateTo, TotalCost)
VALUES (1, '2023-06-05', '2023-06-06', 100),
       (2, '2023-06-06', '2023-06-08', 140),
       (3, '2023-06-07', '2023-06-09', 400),
       (4, '2023-06-08', '2023-06-10', 180);

--- TASK 2 ---

-- Task 2.1 frequent joining of htels and rooms
CREATE INDEX Hotels_Rooms_Index on HotelRoom(
HotelKey ASC,
RoomKey ASC)

-- task 2.2: uniqueness of the HotelName column
CREATE UNIQUE INDEX HotelName_Index ON Hotel (HotelName);

-- task 2.3: filtering rooms by the number of guests
CREATE NONCLUSTERED INDEX Guests_Index ON HotelRoom (NumberOfGuests);

-- task 2.4: primary key in reservations table
-- comment: primary keys are usually indexed already?
CREATE NONCLUSTERED INDEX PK_Index ON Reservation(ReservationKey);

-- task 2.5: filtering reservations by start and end date together 
CREATE NONCLUSTERED INDEX StartEnd_Index ON Reservation(
DateFrom, 
DateTo);

--- TASK 3 ---

CREATE OR ALTER PROCEDURE RoomReservations 
 @HotelName VARCHAR(100),
 @NumberOfGuests INT,
 @DateFrom DATE,
 @DateTo DATE -- 3.1: 4 params
AS 
BEGIN
BEGIN TRANSACTION;
DECLARE @Reserved INT; 
SELECT TOP 1 @Reserved = RoomKey FROM HotelRoom
WHERE HotelKey = (SELECT HotelKey FROM Hotel WHERE HotelName = @HotelName) -- 3.2: search for unreserved room
	  AND isReserved = 0
	  AND NumberOfGuests = @NumberOfGuests
	  AND RoomKey NOT IN (SELECT RoomKey FROM Reservation WHERE DateFrom <= @DateTo AND DateTo >= @DateFrom);

IF @Reserved IS NOT NULL BEGIN
	DECLARE @TotalCost MONEY;
	SELECT @TotalCost = DATEDIFF(DAY, @DateFrom, @DateTo) * CostOfANight -- 3.3 total cost: days * cost per night
	FROM HotelRoom WHERE RoomKey = @Reserved;
	
	INSERT INTO Reservation (RoomKey, DateFrom, DateTo, TotalCost)
	VALUES (@Reserved, @DateFrom, @DateTo, @TotalCost) -- 3.3: insert a new record 
    UPDATE HotelRoom SET isReserved = 1 WHERE RoomKey = @Reserved; -- room is now booked
    
	SELECT * FROM Reservation; 
	SELECT * FROM HotelRoom WHERE RoomKey = @Reserved; -- show hotelroom and reservation tables to see new data
	END
    ELSE BEGIN
	SELECT HotelName, RoomKey, CostOfANight 
	FROM HotelRoom 
	JOIN Hotel on HotelRoom.HotelKey = Hotel.HotelKey
	WHERE City = (SELECT City FROM Hotel WHERE HotelName = @HotelName) -- 4: search hotel in the same city as in first hotel
	AND NumberOfGuests = @NumberOfGuests AND isReserved = 0; -- room should be not reserved
    END
	COMMIT;
END

-- drafts
select DATEDIFF(DAY,DateFrom, DateTo) from Reservation
select * from Reservation;
select * from Hotel;
select * from HotelRoom;

-- if we lok at HotelRoom table we can see that Hilton hotel has rooms for 2 and 3 guests 
-- below is how we can execute the procedure for reserving the room in Hilton
EXECUTE RoomReservations
@HotelName = 'Hilton',
@NumberOfGuests = 2,
@DateFrom = '2023-06-11',
@DateTo = '2023-06-15';
-- so we want to get a room in hilton for 2 people for specified range, as can be seen from table 1 below our 
-- request is done and booking is done with ReservationKey=5 (before it had 4 rows) 
-- table 2 shows us the info about our booking and price per night with status isReserved=1 means booked
-- screen saved to Lab3_Result.png