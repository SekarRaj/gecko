       IDENTIFICATION DIVISION.
       PROGRAM-ID. SQLDEMO.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-DB-NAME        PIC X(18)   VALUE 'YOUR_DB_NAME'.
       01  WS-USER           PIC X(18)   VALUE 'YOUR_USERNAME'.
       01  WS-PASSWORD       PIC X(18)   VALUE 'YOUR_PASSWORD'.
       01  WS-DATA           PIC X(100).
       01  WS-SQLCODE        PIC S9(9) COMP.
       
       EXEC SQL INCLUDE SQLCA END-EXEC.
       
       PROCEDURE DIVISION.
           OPEN-DB.
               MOVE WS-DB-NAME TO DB-NAME
               MOVE WS-USER TO USER
               MOVE WS-PASSWORD TO PASSWORD
               EXEC SQL CONNECT TO :DB-NAME USER :USER USING :PASSWORD END-EXEC
               IF SQLCODE NOT = 0
                   DISPLAY 'ERROR CONNECTING TO DATABASE, SQLCODE: ' SQLCODE
                   STOP RUN
               END-IF.
       
           FETCH-DATA.
               EXEC SQL SELECT COLUMN_NAME INTO :WS-DATA FROM TABLE_NAME END-EXEC
               IF SQLCODE NOT = 0
                   DISPLAY 'ERROR FETCHING DATA, SQLCODE: ' SQLCODE
                   STOP RUN
               END-IF
               DISPLAY 'DATA: ' WS-DATA.
       
           CLOSE-DB.
               EXEC SQL DISCONNECT :DB-NAME END-EXEC
               IF SQLCODE NOT = 0
                   DISPLAY 'ERROR DISCONNECTING FROM DATABASE, SQLCODE: ' SQLCODE
                   STOP RUN
               END-IF.
       
           STOP RUN.