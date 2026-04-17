DROP TABLE Patient_Treatment PURGE;
DROP TABLE Payment PURGE;
DROP TABLE Invoice PURGE;
DROP TABLE Room PURGE;
DROP TABLE Report PURGE;
DROP TABLE Treatment PURGE;
DROP TABLE Appointment PURGE;
DROP TABLE Doctor PURGE;
DROP TABLE Patient PURGE;

CREATE TABLE Patient (
    Patient_ID INT PRIMARY KEY,
    Name VARCHAR2(25) NOT NULL,
    DOB DATE NOT NULL,
    Gender VARCHAR2(10) CHECK (Gender IN ('Male', 'Female', 'Other')),
    Address CLOB,
    Phone VARCHAR2(15) UNIQUE,
    Insurance_Detail CLOB
);

CREATE TABLE Doctor (
    Doctor_ID INT PRIMARY KEY,
    Name VARCHAR2(25) NOT NULL,
    Specialty VARCHAR2(25) NOT NULL,
    Contact VARCHAR2(15) UNIQUE,
    Working_Hours VARCHAR2(20)
);

CREATE TABLE Appointment (
    Appointment_ID INT PRIMARY KEY,
    Patient_ID INT,
    Doctor_ID INT,
    Appointment_Date DATE NOT NULL,
    Appointment_Time TIMESTAMP NOT NULL,
    Purpose CLOB,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID) ON DELETE CASCADE,
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID) ON DELETE SET NULL
);

CREATE TABLE Treatment (
    Treatment_ID INT PRIMARY KEY,
    Doctor_ID INT,
    Treatment_Name VARCHAR2(255) NOT NULL,
    Cost NUMBER(10,2) NOT NULL,
    Start_Date DATE,
    End_Date DATE,
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID) ON DELETE SET NULL
);

CREATE TABLE Report (
    Report_ID INT PRIMARY KEY,
    Patient_ID INT,
    Doctor_ID INT,
    Report_Type VARCHAR2(25) NOT NULL,
    Report_Date DATE NOT NULL,
    Diagnosis CLOB,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID) ON DELETE CASCADE,
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID) ON DELETE SET NULL
);

CREATE TABLE Room (
    Room_ID INT PRIMARY KEY,
    Patient_ID INT,
    Room_Type VARCHAR2(25),
    Floor_Number INT,
    Status VARCHAR2(20) CHECK (Status IN ('Occupied', 'Available')),
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID) ON DELETE SET NULL
);

CREATE TABLE Invoice (
    Invoice_ID INT PRIMARY KEY,
    Patient_ID INT,
    Room_Charges NUMBER(10,2) NOT NULL,
    Treatment_Charges NUMBER(10,2) NOT NULL,
    Total_Amount NUMBER(10,2) NOT NULL,
    Issue_Date DATE NOT NULL,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID) ON DELETE CASCADE
);

CREATE TABLE Payment (
    Payment_ID INT PRIMARY KEY,
    Invoice_ID INT,
    Amount NUMBER(10,2) NOT NULL,
    Payment_Date DATE NOT NULL,
    Payment_Method VARCHAR2(25),
    FOREIGN KEY (Invoice_ID) REFERENCES Invoice(Invoice_ID) ON DELETE CASCADE
);

CREATE TABLE Patient_Treatment (
    Patient_ID INT,
    Treatment_ID INT,
    PRIMARY KEY (Patient_ID, Treatment_ID),
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID) ON DELETE CASCADE,
    FOREIGN KEY (Treatment_ID) REFERENCES Treatment(Treatment_ID) ON DELETE CASCADE
);
