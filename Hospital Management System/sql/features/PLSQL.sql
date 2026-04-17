-- Enhanced PL/SQL for Hospital Management System

DROP TABLE Room_Status_Log;

CREATE TABLE Room_Status_Log (
    Log_ID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Room_ID NUMBER,
    Old_Status VARCHAR2(20),
    New_Status VARCHAR2(20),
    Change_Date DATE
);


-- REQ 2: Improved patient search with better name matching and error handling  
CREATE OR REPLACE FUNCTION Search_Patient(
    p_id IN NUMBER DEFAULT NULL, 
    p_name IN VARCHAR2 DEFAULT NULL
) RETURN SYS_REFCURSOR IS
  result SYS_REFCURSOR;
BEGIN
  IF p_id = 0 AND p_name IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'At least one search parameter (ID or name) must be provided');
  END IF;
  
  OPEN result FOR
  SELECT Patient_ID, Name, DOB, Gender, Address , Phone, Insurance_Detail
  FROM Patient
  WHERE (p_id IS NULL OR Patient_ID = p_id) 
    AND (p_name IS NULL OR REGEXP_LIKE(LOWER(Name), LOWER(p_name), 'i'));
  
  RETURN result;
  DBMS_OUTPUT.PUT_LINE ('REQ 2 FULFLLED');

EXCEPTION
  WHEN OTHERS THEN
    IF result%ISOPEN THEN
      CLOSE result;
    END IF;
    RAISE;
END;
/

-- REQ 3: Enhanced invoice generation with actual invoice creation
CREATE OR REPLACE PROCEDURE Generate_Invoice(p_patient_id IN NUMBER) IS
  v_total_treatment_cost NUMBER := 0;
  v_room_charge NUMBER := 0;
  v_invoice_id NUMBER;
  v_patient_exists NUMBER;
BEGIN
  -- Check if patient exists
  SELECT COUNT(*) INTO v_patient_exists FROM Patient WHERE Patient_ID = p_patient_id;
  IF v_patient_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Patient not found');
  END IF;

  -- Calculate treatment costs from Patient_Treatment junction table (more accurate)
  SELECT NVL(SUM(t.Cost), 0) INTO v_total_treatment_cost
  FROM Treatment t
  JOIN Patient_Treatment pt ON t.Treatment_ID = pt.Treatment_ID
  WHERE pt.Patient_ID = p_patient_id;

  -- Calculate room charges with proper duration calculation
  SELECT CASE r.Room_Type
         WHEN 'Single' THEN 1000
         WHEN 'Deluxe' THEN 2000
         WHEN 'ICU' THEN 3000
         WHEN 'General' THEN 500
         WHEN 'Semi-Private' THEN 800
         ELSE 0 END * 
         (SELECT NVL(MAX(TRUNC(SYSDATE) - TRUNC(a.Appointment_Date)), 1)
          FROM Appointment a
          WHERE a.Patient_ID = p_patient_id)
         INTO v_room_charge
  FROM Room r
  WHERE r.Patient_ID = p_patient_id AND r.Status = 'Occupied';

  -- Generate invoice sequence
  SELECT NVL(MAX(Invoice_ID), 0) + 1 INTO v_invoice_id FROM Invoice;
  
  -- Insert into Invoice table
  INSERT INTO Invoice (Invoice_ID, Patient_ID, Room_Charges, Treatment_Charges, Total_Amount, Issue_Date)
  VALUES (v_invoice_id, p_patient_id, v_room_charge, v_total_treatment_cost, 
          (v_room_charge + v_total_treatment_cost), SYSDATE);
  
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('Invoice generated successfully for Patient ID ' || p_patient_id);
  DBMS_OUTPUT.PUT_LINE('Invoice ID: ' || v_invoice_id);
  DBMS_OUTPUT.PUT_LINE('Treatment Charges: Rs. ' || v_total_treatment_cost);
  DBMS_OUTPUT.PUT_LINE('Room Charges: Rs. ' || v_room_charge);
  DBMS_OUTPUT.PUT_LINE('Total Amount: Rs. ' || (v_total_treatment_cost + v_room_charge));
  DBMS_OUTPUT.PUT_LINE ('REQ 3 FULFLLED');

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error generating invoice: ' || SQLERRM);
    RAISE;
END;
/

-- REQ 5: Enhanced patient update with validation
CREATE OR REPLACE PROCEDURE Update_Patient_Info(
    p_id IN NUMBER, 
    new_contact IN VARCHAR2 DEFAULT NULL,
    new_insurance IN CLOB DEFAULT NULL
) IS
  v_update_count NUMBER := 0;
BEGIN
  IF new_contact IS NULL AND new_insurance IS NULL THEN
    RAISE_APPLICATION_ERROR(-20003, 'At least one update value must be provided');
  END IF;
  
  IF new_contact IS NOT NULL THEN
    -- Validate phone format (simple validation)
    IF NOT REGEXP_LIKE(new_contact, '^[0-9]{10,15}$') THEN
      RAISE_APPLICATION_ERROR(-20004, 'Invalid phone number format');
    END IF;
    
    UPDATE Patient SET Phone = new_contact WHERE Patient_ID = p_id;
    v_update_count := v_update_count + SQL%ROWCOUNT;
  END IF;
  
  IF new_insurance IS NOT NULL THEN
    UPDATE Patient SET Insurance_Detail = new_insurance WHERE Patient_ID = p_id;
    v_update_count := v_update_count + SQL%ROWCOUNT;
  END IF;
  
  IF v_update_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20005, 'Patient ID not found');
  END IF;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Patient information updated successfully');
  DBMS_OUTPUT.PUT_LINE ('REQ 5 FULFLLED');

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/

-- REQ 6: Improved room status trigger with logging
CREATE OR REPLACE TRIGGER trg_clear_patient_on_available  --CLEAR THE PREVIOUSLY OCCUPYING PATENT 
BEFORE UPDATE OF Status ON Room
FOR EACH ROW
BEGIN
  IF :NEW.Status = 'Available' AND :OLD.Status != 'Available' THEN
    :NEW.Patient_ID := NULL;
  END IF;
END;
/


CREATE OR REPLACE TRIGGER trg_log_room_status     --NSERT CHANGES TO LOG TABLE
AFTER UPDATE OF Status ON Room
FOR EACH ROW
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  IF :NEW.Status = 'Available' AND :OLD.Status != 'Available' THEN
    INSERT INTO Room_Status_Log (Room_ID, Old_Status, New_Status, Change_Date)
    VALUES (:NEW.Room_ID, :OLD.Status, :NEW.Status, SYSDATE);
    COMMIT;
  END IF;
END;
/


-- REQ 7: Enhanced appointment conflict check with time window
CREATE OR REPLACE FUNCTION Check_Appointment_Conflict(
    p_doctor_id NUMBER, 
    p_date DATE, 
    p_time TIMESTAMP,
    p_duration_min NUMBER DEFAULT 30
) RETURN VARCHAR2 IS
  v_conflict_count NUMBER;
BEGIN
  IF p_doctor_id IS NULL OR p_date IS NULL OR p_time IS NULL THEN
    RETURN 'Invalid parameters';
  END IF;
  
  SELECT COUNT(*) INTO v_conflict_count
  FROM Appointment
  WHERE Doctor_ID = p_doctor_id 
    AND Appointment_Date = p_date
    AND (
      -- Existing appointment starts during new appointment
      (Appointment_Time >= p_time AND 
       Appointment_Time < p_time + (p_duration_min/1440))
      OR
      -- New appointment starts during existing appointment
      (p_time >= Appointment_Time AND 
       p_time < Appointment_Time + (30/1440)) -- Assuming standard 30-min appointments
    );
  
  IF v_conflict_count > 0 THEN
    RETURN 'Conflict Detected: ' || v_conflict_count || ' overlapping appointment(s)';
  ELSE
    RETURN 'No Conflict';
  END IF;
  DBMS_OUTPUT.PUT_LINE ('REQ 7 FULFLLED');
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'Error checking appointment: ' || SQLERRM;
END;
/

-- REQ 8: Enhanced daily report with counts and formatting
CREATE OR REPLACE PROCEDURE Daily_Report(
    p_date IN DATE DEFAULT TRUNC(SYSDATE),
    p_include_details IN BOOLEAN DEFAULT TRUE
) IS
  v_admission_count NUMBER := 0;
  v_discharge_count NUMBER := 0;
  v_appt_rec Appointment%ROWTYPE;
  v_room_rec Room%ROWTYPE;
BEGIN
  -- Get admission count (appointments)
  SELECT COUNT(*) INTO v_admission_count
  FROM Appointment 
  WHERE TRUNC(Appointment_Date) = TRUNC(p_date);
  
  -- Get discharge count (rooms made available)
  SELECT COUNT(*) INTO v_discharge_count
  FROM Room_Status_Log
  WHERE New_Status = 'Available' AND TRUNC(Change_Date) = TRUNC(p_date);
  
  DBMS_OUTPUT.PUT_LINE('=== DAILY HOSPITAL REPORT FOR ' || TO_CHAR(p_date, 'DD-MON-YYYY') || ' ===');
  DBMS_OUTPUT.PUT_LINE('Total Admissions: ' || v_admission_count);
  DBMS_OUTPUT.PUT_LINE('Total Discharges: ' || v_discharge_count);
  
  IF p_include_details THEN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Admission Details ---');
    FOR appt_rec IN (
      SELECT a.Appointment_ID, p.Name AS Patient_Name, d.Name AS Doctor_Name, 
             TO_CHAR(a.Appointment_Time, 'HH24:MI') AS Time
      FROM Appointment a
      JOIN Patient p ON a.Patient_ID = p.Patient_ID
      JOIN Doctor d ON a.Doctor_ID = d.Doctor_ID
      WHERE TRUNC(a.Appointment_Date) = TRUNC(p_date)
      ORDER BY a.Appointment_Time
    ) LOOP
      DBMS_OUTPUT.PUT_LINE('Time: ' || appt_rec.Time || ' | Patient: ' || appt_rec.Patient_Name || 
                          ' | Doctor: ' || appt_rec.Doctor_Name);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Discharge Details ---');
    FOR room_rec IN (
      SELECT r.Room_ID, r.Room_Type, p.Name AS Patient_Name
      FROM Room_Status_Log l
      JOIN Room r ON l.Room_ID = r.Room_ID
      LEFT JOIN Patient p ON r.Patient_ID = p.Patient_ID
      WHERE l.New_Status = 'Available' AND TRUNC(l.Change_Date) = TRUNC(p_date)
    ) LOOP
      DBMS_OUTPUT.PUT_LINE('Room: ' || room_rec.Room_Type || ' ' || room_rec.Room_ID || 
                          ' | Patient: ' || NVL(room_rec.Patient_Name, 'N/A'));
    END LOOP;
  END IF;
  
  DBMS_OUTPUT.PUT_LINE('=== END OF REPORT ===');
  DBMS_OUTPUT.PUT_LINE ('REQ 8 FULFLLED');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error generating report: ' || SQLERRM);
END;    
/


-- Additional utility function to calculate patient bill
CREATE OR REPLACE FUNCTION Calculate_Patient_Balance(
    p_patient_id IN NUMBER
) RETURN NUMBER IS
  v_total_invoiced NUMBER := 0;
  v_total_paid NUMBER := 0;
BEGIN
  -- Get total invoiced amount
  SELECT NVL(SUM(Total_Amount), 0) INTO v_total_invoiced
  FROM Invoice
  WHERE Patient_ID = p_patient_id;
  
  -- Get total payments made
  SELECT NVL(SUM(p.Amount), 0) INTO v_total_paid
  FROM Payment p
  JOIN Invoice i ON p.Invoice_ID = i.Invoice_ID
  WHERE i.Patient_ID = p_patient_id;
  
  RETURN (v_total_invoiced - v_total_paid);
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/