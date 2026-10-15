
-- CREATE DATABASE
CREATE DATABASE IF NOT EXISTS SmartCareDB;
USE SmartCareDB;

-- TABLE: MedicalCentre
CREATE TABLE MedicalCentre (
    CentreID     INT AUTO_INCREMENT PRIMARY KEY,
    CentreName   VARCHAR(150) NOT NULL,
    Address      VARCHAR(255) NOT NULL,
    City         VARCHAR(100) NOT NULL,
    ContactNo    VARCHAR(20),
    Email        VARCHAR(100)
);

-- TABLE: Patient
CREATE TABLE Patient (
    PatientID        INT AUTO_INCREMENT PRIMARY KEY,
    FirstName        VARCHAR(100) NOT NULL,
    LastName         VARCHAR(100) NOT NULL,
    DateOfBirth      DATE NOT NULL,
    Gender           ENUM('Male','Female','Other') NOT NULL,
    NIC              VARCHAR(20) UNIQUE NOT NULL,
    ContactNo        VARCHAR(20),
    Email            VARCHAR(100),
    Address          VARCHAR(255),
    RegistrationDate DATE DEFAULT (CURRENT_DATE)
);

-- TABLE: Doctor
CREATE TABLE Doctor (
    DoctorID        INT AUTO_INCREMENT PRIMARY KEY,
    FirstName       VARCHAR(100) NOT NULL,
    LastName        VARCHAR(100) NOT NULL,
    Specialisation  VARCHAR(150) NOT NULL,
    ContactNo       VARCHAR(20),
    Email           VARCHAR(100),
    CentreID        INT NOT NULL,
    CONSTRAINT FK_Doctor_Centre
        FOREIGN KEY (CentreID) REFERENCES MedicalCentre(CentreID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- TABLE: Appointment
CREATE TABLE Appointment (
    AppointmentID   INT AUTO_INCREMENT PRIMARY KEY,
    PatientID       INT NOT NULL,
    DoctorID        INT NOT NULL,
    CentreID        INT NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    Status          ENUM('Scheduled','Completed','Cancelled','No-Show')
                    DEFAULT 'Scheduled',
    Notes           TEXT,
    CONSTRAINT FK_Appt_Patient
        FOREIGN KEY (PatientID) REFERENCES Patient(PatientID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT FK_Appt_Doctor
        FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT FK_Appt_Centre
        FOREIGN KEY (CentreID) REFERENCES MedicalCentre(CentreID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- TABLE: Treatment
CREATE TABLE Treatment (
    TreatmentID     INT AUTO_INCREMENT PRIMARY KEY,
    AppointmentID   INT NOT NULL,
    TreatmentType   VARCHAR(150) NOT NULL,
    Description     TEXT,
    Cost            DECIMAL(10,2) DEFAULT 0.00,
    TreatmentDate   DATE,
    CONSTRAINT FK_Treat_Appt
        FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- TABLE: Prescription
CREATE TABLE Prescription (
    PrescriptionID   INT AUTO_INCREMENT PRIMARY KEY,
    AppointmentID    INT NOT NULL UNIQUE,
    DoctorID         INT NOT NULL,
    PrescriptionDate DATE NOT NULL,
    Notes            TEXT,
    CONSTRAINT FK_Presc_Appt
        FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_Presc_Doctor
        FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- TABLE: Medicine
CREATE TABLE Medicine (
    MedicineID      INT AUTO_INCREMENT PRIMARY KEY,
    MedicineName    VARCHAR(200) NOT NULL,
    Dosage          VARCHAR(100),
    Unit            VARCHAR(50),
    Description     TEXT
);

-- TABLE: PrescriptionDetail (Junction)
CREATE TABLE PrescriptionDetail (
    PrescDetailID   INT AUTO_INCREMENT PRIMARY KEY,
    PrescriptionID  INT NOT NULL,
    MedicineID      INT NOT NULL,
    Quantity        INT NOT NULL,
    Instructions    VARCHAR(255),
    CONSTRAINT FK_PD_Presc
        FOREIGN KEY (PrescriptionID) REFERENCES Prescription(PrescriptionID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_PD_Med
        FOREIGN KEY (MedicineID) REFERENCES Medicine(MedicineID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- TABLE: Bill
CREATE TABLE Bill (
    BillID          INT AUTO_INCREMENT PRIMARY KEY,
    AppointmentID   INT NOT NULL UNIQUE,
    PatientID       INT NOT NULL,
    TotalAmount     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    AmountPaid      DECIMAL(10,2) DEFAULT 0.00,
    PaymentStatus   ENUM('Pending','Paid','Partially Paid') DEFAULT 'Pending',
    PaymentDate     DATE,
    PaymentMethod   VARCHAR(100),
    CONSTRAINT FK_Bill_Appt
        FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT FK_Bill_Patient
        FOREIGN KEY (PatientID) REFERENCES Patient(PatientID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ==============================================
-- ALTER TABLE Examples
-- ==============================================

-- Add BloodGroup column to Patient
ALTER TABLE Patient ADD COLUMN BloodGroup VARCHAR(10) AFTER Gender;

-- Add INDEX on Appointment date
ALTER TABLE Appointment ADD INDEX idx_appt_date (AppointmentDate);

-- Add a constraint for Bill amount check
ALTER TABLE Bill ADD CONSTRAINT chk_amount
    CHECK (AmountPaid <= TotalAmount);
