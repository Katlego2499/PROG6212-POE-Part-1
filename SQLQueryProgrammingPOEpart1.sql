/*
   1. ROLES TABLE
   */
CREATE TABLE Roles (
    RoleId      INT IDENTITY(1,1) PRIMARY KEY,
    RoleName    VARCHAR(20) NOT NULL UNIQUE
);

/* 
   2. USERS TABLE
   
   */
CREATE TABLE Users (
    UserId        INT IDENTITY(1,1) PRIMARY KEY,
    FullName      VARCHAR(100) NOT NULL,
    Email         VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash  VARCHAR(255) NOT NULL,
    PhoneNumber   VARCHAR(20) NULL,
    RoleId        INT NOT NULL,
    CreatedAt     DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId)
        REFERENCES Roles(RoleId)
);

/* 
   3. EVENTS TABLE
   
   */
CREATE TABLE Events (
    EventId       INT IDENTITY(1,1) PRIMARY KEY,
    EventName     VARCHAR(150) NOT NULL,
    EventDate     DATE NOT NULL,
    Location      VARCHAR(150) NOT NULL,
    Description   VARCHAR(500) NULL,
    OrganiserId   INT NOT NULL,
    CreatedAt     DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Users FOREIGN KEY (OrganiserId)
        REFERENCES Users(UserId)
);

/* 
   4. CATEGORIES TABLE
   
   */
CREATE TABLE Categories (
    CategoryId    INT IDENTITY(1,1) PRIMARY KEY,
    EventId       INT NOT NULL,
    CategoryName  VARCHAR(50) NOT NULL,
    DistanceKm    DECIMAL(5,2) NOT NULL,
    EntryFee      DECIMAL(8,2) NOT NULL DEFAULT 0,
    MaxParticipants INT NULL,
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventId)
        REFERENCES Events(EventId)
);

/* 
   5. ENROLMENTS TABLE
   
   */
CREATE TABLE Enrolments (
    EnrolmentId    INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantId  INT NOT NULL,
    CategoryId     INT NOT NULL,
    EnrolmentDate  DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (ParticipantId)
        REFERENCES Users(UserId),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryId)
        REFERENCES Categories(CategoryId),
    CONSTRAINT UQ_Enrolment UNIQUE (ParticipantId, CategoryId) -- prevents duplicate enrolment
);

/*
   6. RESULTS TABLE
   One result per Enrolment, captured by an Organiser.
   */
CREATE TABLE Results (
    ResultId      INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId   INT NOT NULL UNIQUE, -- enforces one-to-one with Enrolments
    FinishTime    TIME NOT NULL,
    Position      INT NULL,
    CapturedAt    DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentId)
        REFERENCES Enrolments(EnrolmentId)
);

/* 
   SEED DATA
    */

-- Roles
INSERT INTO Roles (RoleName) VALUES ('Organiser'), ('Participant');

-- Users
INSERT INTO Users (FullName, Email, PasswordHash, PhoneNumber, RoleId)
VALUES
('Thabo Mokoena', 'thabo.mokoena@raceday.co.za', 'hashed_pw_1', '0821234567', 1), -- Organiser
('Lindiwe Dlamini', 'lindiwe.dlamini@raceday.co.za', 'hashed_pw_2', '0837654321', 1), -- Organiser
('Sipho Nkosi', 'sipho.nkosi@gmail.com', 'hashed_pw_3', '0724561234', 2), -- Participant
('Anja van der Merwe', 'anja.vdm@gmail.com', 'hashed_pw_4', '0768889999', 2); -- Participant

-- Events
INSERT INTO Events (EventName, EventDate, Location, Description, OrganiserId)
VALUES
('Johannesburg City Run', '2026-11-15', 'Johannesburg, Gauteng', 'A scenic run through the streets of Johannesburg.', 1),
('Cape Town Cycle Challenge', '2026-11-22', 'Cape Town, Western Cape', 'A community cycling event around the Cape Peninsula.', 2),
('Durban Beachfront Walk', '2026-12-05', 'Durban, KwaZulu-Natal', 'A family-friendly walk along the Durban beachfront.', 1);

-- Categories
INSERT INTO Categories (EventId, CategoryName, DistanceKm, EntryFee, MaxParticipants)
VALUES
(1, '5km Fun Run', 5.00, 100.00, 500),
(1, '10km Challenge', 10.00, 150.00, 300),
(2, '40km Road Cycle', 40.00, 250.00, 200),
(2, '80km Road Cycle', 80.00, 350.00, 150),
(3, '3km Family Walk', 3.00, 50.00, 400);

-- Enrolments: sample participants enrolling
INSERT INTO Enrolments (ParticipantId, CategoryId)
VALUES
(3, 1),  -- Sipho enters 5km Fun Run
(3, 3),  -- Sipho enters 40km Road Cycle
(4, 2),  -- Anja enters 10km Challenge
(4, 5);  -- Anja enters 3km Family Walk

-- Results: sample results captured for some enrolments
INSERT INTO Results (EnrolmentId, FinishTime, Position)
VALUES
(1, '00:25:34', 12),
(3, '00:52:10', 8);
