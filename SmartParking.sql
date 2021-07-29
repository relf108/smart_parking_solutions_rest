-- DROP TABLE tbl_booking;
-- DROP TABLE tbl_tokens;
-- DROP TABLE tbl_user;
CREATE TABLE IF NOT EXISTS tbl_user (
    userID int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    googleUserID VARCHAR(255),
    givenName varchar(255),
    familyName varchar(255),
    email varchar(255),
    password VARCHAR(255),
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
CREATE TABLE IF NOT EXISTS tbl_tokens (
    tokenID int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    tokenValue VARCHAR(255),
    createdDate DATETIME,
    ownerFK int,
    FOREIGN KEY (ownerFK) REFERENCES tbl_user(userID)
)