       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMPREC.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 EMPLOYEE-RECORD.
           05 ENO PIC 9(4).
           05 LNAME PIC X(10).
           05 FNAME PIC X(8).
           05 STREET PIC X(20).
           05 CITY PIC X(15).
           05 ST PIC X(2).
           05 ZIP PIC 9(5).
           05 DEPT PIC X(4).
           05 PAYRATE PIC $$$,$$$,$$9.99.
           05 COM PIC Z.99.