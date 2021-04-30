CREATE TABLE IF NOT EXISTS tbl_user (
    userID int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    givenName varchar(255),
    familyName varchar(255),
    email varchar(255),
    handicapped boolean
);
CREATE TABLE IF NOT EXISTS tbl_booking (
    bookingID int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    bayID varchar(255),
    createdDate DATETIME,
    startDate DATETIME,
    endDate DATETIME,
    ownerFK int,
    FOREIGN KEY (ownerFK) REFERENCES tbl_user(userID)
);