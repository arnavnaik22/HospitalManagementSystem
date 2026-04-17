-- Insert data into Patient table
INSERT INTO Patient (Patient_ID, Name, DOB, Gender, Address, Phone, Insurance_Detail) VALUES
(1, 'John Doe', TO_DATE('1980-05-14', 'YYYY-MM-DD'), 'Male', '123 Elm St', '555-1001', 'ABC Insurance'),
(2, 'Jane Smith', TO_DATE('1992-07-21', 'YYYY-MM-DD'), 'Female', '456 Oak St', '555-1002', 'XYZ Insurance'),
(3, 'Michael Johnson', TO_DATE('1985-12-05', 'YYYY-MM-DD'), 'Male', '789 Pine St', '555-1003', 'LMN Insurance'),
(4, 'Emily Davis', TO_DATE('1998-03-30', 'YYYY-MM-DD'), 'Female', '321 Maple St', '555-1004', 'PQR Insurance'),
(5, 'Daniel Brown', TO_DATE('1975-09-18', 'YYYY-MM-DD'), 'Male', '654 Birch St', '555-1005', 'ABC Insurance'),
(6, 'Sarah Wilson', TO_DATE('1990-11-23', 'YYYY-MM-DD'), 'Female', '987 Cedar St', '555-1006', 'XYZ Insurance'),
(7, 'David Martinez', TO_DATE('1982-07-07', 'YYYY-MM-DD'), 'Male', '741 Spruce St', '555-1007', 'LMN Insurance'),
(8, 'Laura Thompson', TO_DATE('1995-02-14', 'YYYY-MM-DD'), 'Female', '852 Walnut St', '555-1008', 'PQR Insurance'),
(9, 'James Anderson', TO_DATE('1978-08-22', 'YYYY-MM-DD'), 'Male', '963 Chestnut St', '555-1009', 'ABC Insurance'),
(10, 'Olivia White', TO_DATE('1987-06-17', 'YYYY-MM-DD'), 'Female', '159 Redwood St', '555-1010', 'XYZ Insurance');

-- Insert data into Doctor table
INSERT INTO Doctor (Doctor_ID, Name, Specialty, Contact, Working_Hours) VALUES
(1, 'Dr. Alice Brown', 'Cardiology', '555-2001', '9 AM - 5 PM'),
(2, 'Dr. Bob White', 'Neurology', '555-2002', '10 AM - 6 PM'),
(3, 'Dr. Charlie Green', 'Orthopedics', '555-2003', '8 AM - 4 PM'),
(4, 'Dr. Diana Black', 'Pediatrics', '555-2004', '11 AM - 7 PM'),
(5, 'Dr. Evan Grey', 'Dermatology', '555-2005', '9 AM - 3 PM');

-- Insert data into Appointment table
INSERT INTO Appointment (Appointment_ID, Patient_ID, Doctor_ID, Appointment_Date, Appointment_Time, Purpose) VALUES
(1, 1, 1, TO_DATE('2025-03-27', 'YYYY-MM-DD'), TO_TIMESTAMP('10:00:00', 'HH24:MI:SS'), 'Regular Checkup'),
(2, 2, 2, TO_DATE('2025-03-28', 'YYYY-MM-DD'), TO_TIMESTAMP('11:30:00', 'HH24:MI:SS'), 'Consultation'),
(3, 3, 3, TO_DATE('2025-03-29', 'YYYY-MM-DD'), TO_TIMESTAMP('14:00:00', 'HH24:MI:SS'), 'Fracture Checkup'),
(4, 4, 4, TO_DATE('2025-03-30', 'YYYY-MM-DD'), TO_TIMESTAMP('16:30:00', 'HH24:MI:SS'), 'Child Vaccination'),
(5, 5, 5, TO_DATE('2025-03-31', 'YYYY-MM-DD'), TO_TIMESTAMP('09:45:00', 'HH24:MI:SS'), 'Skin Allergy Consultation');

-- Insert data into Treatment table
INSERT INTO Treatment (Treatment_ID, Doctor_ID, Treatment_Name, Cost, Start_Date, End_Date) VALUES
(1, 1, 'Heart Surgery', 5000.00, TO_DATE('2025-02-01', 'YYYY-MM-DD'), TO_DATE('2025-02-10', 'YYYY-MM-DD')),
(2, 2, 'Brain MRI', 1500.00, TO_DATE('2025-03-05', 'YYYY-MM-DD'), NULL),
(3, 3, 'Knee Replacement', 10000.00, TO_DATE('2025-01-15', 'YYYY-MM-DD'), TO_DATE('2025-01-30', 'YYYY-MM-DD')),
(4, 4, 'Flu Treatment', 300.00, TO_DATE('2025-03-10', 'YYYY-MM-DD'), TO_DATE('2025-03-12', 'YYYY-MM-DD')),
(5, 5, 'Acne Therapy', 500.00, TO_DATE('2025-02-20', 'YYYY-MM-DD'), TO_DATE('2025-03-05', 'YYYY-MM-DD'));

-- Insert data into Report table
INSERT INTO Report (Report_ID, Patient_ID, Doctor_ID, Report_Type, Report_Date, Diagnosis) VALUES
(1, 1, 1, 'ECG', TO_DATE('2025-03-01', 'YYYY-MM-DD'), 'Normal'),
(2, 2, 2, 'MRI Scan', TO_DATE('2025-03-06', 'YYYY-MM-DD'), 'Mild anomaly detected'),
(3, 3, 3, 'X-Ray', TO_DATE('2025-02-15', 'YYYY-MM-DD'), 'Fracture healing well'),
(4, 4, 4, 'Blood Test', TO_DATE('2025-03-11', 'YYYY-MM-DD'), 'All levels normal'),
(5, 5, 5, 'Skin Biopsy', TO_DATE('2025-03-07', 'YYYY-MM-DD'), 'No malignancy found');

-- Insert data into Room table
INSERT INTO Room (Room_ID, Patient_ID, Room_Type, Floor_Number, Status) VALUES
(101, 1, 'Single', 2, 'Occupied'),
(102, 2, 'Deluxe', 3, 'Available'),
(103, 3, 'ICU', 1, 'Occupied'),
(104, 4, 'General', 4, 'Available'),
(105, 5, 'Semi-Private', 2, 'Occupied');
