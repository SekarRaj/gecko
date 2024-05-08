        IDENTIFICATION DIVISION.
        PROGRAM-ID.  UMPP2.
        AUTHOR. STV GROUP.
        INSTALLATION. TERADATA STV.
        DATE-WRITTEN.
        DATE-COMPILED.
        REMARKS.
        
       ***************************************************************
       * F.2
       * Title:        UMPP2  -  Cobol PP2 Host umbrella program
       *
       * Copyright:    (C) 1988 by Teradata Corporation,
       *                       Los Angeles, CA 90066
       *
       * DataBase: [any database in which the following table exists]
       *
       * Table:        HUTestResults
       *
       * Description:  This program will:
       *                - LOGON to a Teradata DBS using the logon string
       *                  stored in the variable ’LOGON-STR’.
       *                - INSERT five rows into HUTestResults.
       *                - UPDATE row number 4.
       *                - DELETE row number 2.
       *                - SELECT all the rows from HUTestResults.
       *                - LOGOFF.
       *
       * Comments:   The Logon String is set to LOGON-STR via the
       *             value clause for LOGON-STR.
       *
       *             Execute the following BTEQ script to create the
       *             HUTestResults table:
       *
       *             CREATE TABLE HUTestResults, FALLBACK
       *                          (
       *                          SourceOfRow         VARCHAR(30)  ,
       *                          ROWNUMBER           INTEGER      ,
       *                          col001              BYTE(4)      ,
       *                          col002              BYTEINT      ,
       *                          col003              CHAR(8)      ,
       *                          col004              DATE         ,
       *                          col005              DECIMAL(8,3) ,
       *                          col006              FLOAT        ,
       *                          col007              INTEGER      ,
       *                          col008              SMALLINT     ,
       *                          col009              VARBYTE(8)   ,
       *                          col010              VARCHAR(15)
       *                          )
       *                    PRIMARY INDEX (SourceOfRow, ROWNUMBER) ;
       *
       *             COL001 and COL009 are NOT fetched during the
       *             select because their data types are BYTE and
       *             VARBYTE, respectively, and these data types
       *             are not supported by the Cobol PP2.
       *
       * History   F.1   88SEP12   EDS   Coded new UM-PP2 application
       *           F.2   88SEP14   OMH   CICS version of application
       *****************************************************************
        
        ENVIRONMENT DIVISION.
        
        CONFIGURATION SECTION.
        SOURCE-COMPUTER. IBM-370.
        OBJECT-COMPUTER. IBM-370.
        INPUT-OUTPUT SECTION.
        FILE-CONTROL.
        
        DATA DIVISION.
        
        FILE SECTION.
        
        WORKING-STORAGE SECTION.
        
            EXEC SQL INCLUDE SQLCA END-EXEC.
        
        01  P-CODE                 PIC S9(4)   COMP  VALUE +0.
        
        01  P-CODE-DEFS.
            05 OK                   PIC S9(4)   COMP  VALUE +0.
            05 EOF                  PIC S9(4)   COMP  VALUE -1.
            05 TRY-AGAIN            PIC S9(4)   COMP  VALUE -2.
            05 FATAL-ERR            PIC S9(4)   COMP  VALUE -9.
        
        01  P-RETRY                PIC S9(4)   COMP  VALUE +0.
        
        01  P-PGPH-NAME            PIC X(30)   VALUE SPACES.
        
        01  EOF-SW                 PIC X VALUE IS ’N’.
            88 ITS-EOF                  VALUE IS ’Y’.
            88 NOT-EOF                  VALUE IS ’N’.
        
        01  USER-NAME              PIC -(9).
        
        01  LOGON-STR.
            49 FILLER             PIC S9(2) COMP VALUE +80.
            49 FILLER             PIC X(80)
                                      VALUE ’tdpid/uid,pswd’.
        
        01  H-COL001              PIC X(4).
        01  H-COL002              PIC S9(2) COMP.
        01  H-COL003              PIC X(8).
        01  H-COL004              PIC S9(6) COMP.
        01  H-COL006              USAGE IS COMP-2.
        01  H-COL007              PIC S9(9) COMP.
        01  H-COL008              PIC S9(4) COMP.
        01  H-COL009.
            49 H-COL009-L         PIC S9(4) COMP.
            49 H-COL009-V         PIC X(8).
        
        01  H-COL010.
            49 H-COL010-L         PIC S9(4) COMP.
            49 H-COL010-V         PIC X(15).
        
        01  I1                    PIC S9(4) COMP.
        01  I2                    PIC S9(4) COMP.
        01  I3                    PIC S9(4) COMP.
        01  I4                    PIC S9(4) COMP.
        01  I5                    PIC S9(4) COMP.
        01  I6                    PIC S9(4) COMP.
        01  I7                    PIC S9(4) COMP.
        01  I8                    PIC S9(4) COMP.
        01  I9                    PIC S9(4) COMP.
        01  I10                   PIC S9(4) COMP.
        
        01  SCREEN-MESSAGE         PIC X(60).
        
        01  MESSAGE-OUT.
            05  PGPHNAME          PIC X(30)  DISPLAY.
            05  ERRCODE           PIC -(12).
        
        PROCEDURE DIVISION.
        
       ***************************************************************
       *                                                             *
       *   Logon                                                     *
       *                                                             *
       ***************************************************************
        
        SQL-CODE.
        
            EXEC SQL
              LOGON :LOGON-STR  END-EXEC.
        
            IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
        
            IF P-CODE EQUAL FATAL-ERR THEN
              GO TO SQL-CODE-EXIT.
        
            MOVE ’LOGGED ON OK ...’ TO SCREEN-MESSAGE.
            EXEC CICS SEND TEXT FROM(SCREEN-MESSAGE)
                 LENGTH(60) FREEKB ERASE
            END-EXEC.
        
        SQL-CODE-002.
        
       ***************************************************************
       *                                                             *
       *   Insert the first row                                      *
       *                                                             *
       ***************************************************************
        
              MOVE ’SQL-CODE-002’ TO P-PGPH-NAME.
            EXEC SQL
                  INSERT INTO HUTESTRESULTS VALUES
                  ( ’Preprocessor2/COBOL/CICS’ ,
                    1                ,
                    ’00010203’XB     ,
                    -128             ,
                    ’        ’       ,
                    000101           ,
                    0.01             ,
                    5.4e-79          ,
                    -2147483648      ,
                    -32768           ,
                    ’00’XB           ,
                    ’ ’
                  )
            END-EXEC.
            IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
            IF P-CODE EQUAL FATAL-ERR THEN
              GO TO SQL-CODE-EXIT.
            PERFORM 0200-COMMIT.
            MOVE ’FINISHED REQUEST 002...’ TO SCREEN-MESSAGE.
            EXEC CICS SEND TEXT FROM(SCREEN-MESSAGE)
                 LENGTH(60) FREEKB ERASE
            END-EXEC.
        
        SQL-CODE-003.
        
       ***************************************************************
       *                                                             *
       *   Insert the second row                                     *
       *                                                             *
       ***************************************************************
        
              MOVE ’SQL-CODE-003’ TO P-PGPH-NAME.
            EXEC SQL
                  INSERT INTO HUTESTRESULTS VALUES
                  ( ’Preprocessor2/COBOL/CICS’ ,
                    2                   ,
                    ’FCFDFEFF’XB        ,
                    127                 ,
                    ’99999999’          ,
                    991231              ,
                    99999.999           ,
                    .72e76              ,
                    2147483647          ,
                    32767               ,
                    ’F8F9FAFBFCFDFEFF’XB,
                    ’}}}}}}}}}}}}}}}’
                  )
            END-EXEC.
            
       IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
        
            IF P-CODE EQUAL FATAL-ERR THEN
              GO TO SQL-CODE-EXIT.
        
        
            PERFORM 0200-COMMIT.
        
            MOVE ’FINISHED REQUEST 003...’ TO SCREEN-MESSAGE.
            EXEC CICS SEND TEXT FROM(SCREEN-MESSAGE)
                 LENGTH(60) FREEKB ERASE
            END-EXEC.
        
       SQL-CODE-004.
        
       ***************************************************************
       *                                                             *
       *   Insert the third row                                      *
       *                                                             *
       ***************************************************************
        
             MOVE ’SQL-CODE-004’ TO P-PGPH-NAME.
            EXEC SQL
                  INSERT INTO HUTESTRESULTS VALUES
                  ( ’Preprocessor2/COBOL/CICS’ ,
                    3                ,
                                     ,
                                     ,
                                     ,
                                     ,
                                     ,
                                     ,
                                     ,
                                     ,
                                     ,
                 )
            END-EXEC.
            
            IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
        
            IF P-CODE EQUAL FATAL-ERR THEN
              GO TO SQL-CODE-EXIT.
        
            PERFORM 0200-COMMIT.
        
            MOVE ’FINISHED REQUEST 004...’ TO SCREEN-MESSAGE.
            EXEC CICS SEND TEXT FROM(SCREEN-MESSAGE)
                 LENGTH(60) FREEKB ERASE
            END-EXEC.
        
        SQL-CODE-005.
        
       ***************************************************************
       *                                                             *
       *   Insert the fourth row                                     *
       *                                                             *
       ***************************************************************
        
              MOVE ’SQL-CODE-005’ TO P-PGPH-NAME.
            EXEC SQL
                  INSERT INTO HUTESTRESULTS VALUES
                  ( ’Preprocessor2/COBOL/CICS’ ,
                    4                   ,
                                       ,
                                       ,
                                       ,
                                       ,
                                       ,
                                       ,
                                       ,
                                       ,
                                       ,
                 )
            END-EXEC.
        
            IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
        
            IF P-CODE EQUAL FATAL-ERR THEN
              GO TO SQL-CODE-EXIT.
        
            PERFORM 0200-COMMIT.
        
            MOVE ’FINISHED REQUEST 005...’ TO SCREEN-MESSAGE.
            EXEC CICS SEND TEXT FROM(SCREEN-MESSAGE)
                 LENGTH(60) FREEKB ERASE
            END-EXEC.
        
        SQL-CODE-006.
        
       ***************************************************************
       *                                                             *
       *   Insert the fifth row                                      *
       *                                                             *
       ***************************************************************
        
              MOVE ’SQL-CODE-006’ TO P-PGPH-NAME.
            EXEC SQL
                  INSERT INTO HUTESTRESULTS VALUES
                  ( ’Preprocessor2/COBOL/CICS’ ,
                    5                   ,
                    ’FCFDFEFF’XB        ,
                    127                 ,
                    ’99999999’          ,
                    991231              ,
                    99999.999           ,
                    .72e76              ,
                    2147483647          ,
                    32767               ,
                    ’F8F9FAFBFCFDFEFF’XB,
                    ’}}}}}}}}}}}}}}}’
                  )
            END-EXEC.
        
            IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
        
            IF P-CODE EQUAL FATAL-ERR THEN
              GO TO SQL-CODE-EXIT.
        
            PERFORM 0200-COMMIT.
        
            MOVE ’FINISHED REQUEST 006...’ TO SCREEN-MESSAGE.
            EXEC CICS SEND TEXT FROM(SCREEN-MESSAGE)
                 LENGTH(60) FREEKB ERASE
            END-EXEC.
        
        SQL-CODE-007.
        
       ***************************************************************
       *                                                             *
       *   Update row four.                                          *
       *                                                             *
       ***************************************************************
        
              MOVE ’SQL-CODE-007’ TO P-PGPH-NAME.
            EXEC SQL
                  UPDATE HUTESTRESULTS SET
                    COL001 = ’77’XB     ,
                    COL002 = 100        ,
                    COL003 = ’AAAA’     ,
                    COL004 = 500615     ,
                    COL005 = 11111.222  ,
                    COL006 = 1.2345E6   ,
                    COL007 = 12345678   ,
                    COL008 = 12345      ,
                    COL009 = ’888888’XB ,
                    COL010 = ’ZZZZZZZZ’
                  WHERE SOURCEOFROW = ’Preprocessor2/COBOL/CICS’
                  AND ROWNUMBER = 4
            END-EXEC.
        
            IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
        
            IF P-CODE EQUAL FATAL-ERR THEN
              GO TO SQL-CODE-EXIT.
        
            PERFORM 0200-COMMIT.
        
            MOVE ’FINISHED REQUEST 007...’ TO SCREEN-MESSAGE.
            EXEC CICS SEND TEXT FROM(SCREEN-MESSAGE)
                 LENGTH(60) FREEKB ERASE
            END-EXEC.
        
        SQL-CODE-008.
        
       ***************************************************************
       *                                                             *
       *   Delete row two.                                           *
       *                                                             *
       ***************************************************************
         
              MOVE ’SQL-CODE-008’ TO P-PGPH-NAME.
            EXEC SQL
                  DELETE FROM HUTESTRESULTS
                  WHERE SOURCEOFROW = ’Preprocessor2/COBOL/CICS’
                  AND ROWNUMBER = 2
            END-EXEC.
        
            IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
        
            IF P-CODE EQUAL FATAL-ERR THEN
              GO TO SQL-CODE-EXIT.
        
            PERFORM 0200-COMMIT.
        
            MOVE ’FINISHED REQUEST 008...’ TO SCREEN-MESSAGE.
            EXEC CICS SEND TEXT FROM(SCREEN-MESSAGE)
                 LENGTH(60) FREEKB ERASE
            END-EXEC.
        
        SQL-CODE-009.
        
       ***************************************************************
       *                                                             *
       *   Select all the rows.                                      *
       *                                                             *
       *        1)  Declare a CURSOR for the SELECT statement.       *
       *                                                             *
       ***************************************************************
        
              MOVE ’SQL-CODE-009’ TO P-PGPH-NAME.
            EXEC SQL
              DECLARE CURSOR-009 CURSOR FOR
                  SELECT COL002,
                         COL003,
                         COL004,
                         COL005,
                         COL006,
                         COL007,
                         COL008,
                         COL010
                  FROM HUTESTRESULTS
              END-EXEC.
        
            IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
        
            IF P-CODE EQUAL FATAL-ERR THEN
        
       ***************************************************************
       *                                                             *
       *        2)  Now OPEN the CURSOR (OPEN executes the SELECT).  *
       *                                                             *
       ***************************************************************
        
              GO TO SQL-CODE-EXIT.
        
            EXEC SQL
              OPEN CURSOR-009 END-EXEC.
        
            IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
        
            IF P-CODE EQUAL FATAL-ERR THEN
              GO TO SQL-CODE-EXIT.
        
        POSITION-CURSOR-00901.
        
       ***************************************************************
       *                                                             *
       *        3)  POSITION to the first statement (required for a  *
       *            multi-statement request, optional in this case). *
       *                                                             *
       ***************************************************************
        
            EXEC SQL
              POSITION CURSOR-009 TO STATEMENT 1  END-EXEC.
        
            IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
        
            IF P-CODE EQUAL FATAL-ERR THEN
              GO TO SQL-CODE-EXIT.
        
        FETCH-CURSOR-00901.
        
       ***************************************************************
       *                                                             *
       *        4)  FETCH the values from the table.                 *
       *                                                             *
       ***************************************************************
        
            EXEC SQL
              FETCH CURSOR-009 INTO
              :H-COL002 :I2, :H-COL003 :I3, :H-COL004 :I4,
              :H-COL005 :I5, :H-COL006 :I6, :H-COL007 :I7,
              :H-COL008 :I8, :H-COL010 :I10 END-EXEC.
        
            IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
        
            IF P-CODE EQUAL FATAL-ERR THEN
              GO TO SQL-CODE-EXIT.
        
            IF P-CODE EQUAL EOF THEN
              GO TO EOF-CURSOR-00901.
        
            GO TO FETCH-CURSOR-00901.
        
        EOF-CURSOR-00901.
        
       ***************************************************************
       *                                                             *
       *        5)  CLOSE the cursor.                                *
       *                                                             *
       ***************************************************************
        
            EXEC SQL
              CLOSE CURSOR-009 END-EXEC.
        
            IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
        
            IF P-CODE EQUAL FATAL-ERR THEN
              GO TO SQL-CODE-EXIT.
        
            PERFORM 0200-COMMIT.
        
            MOVE ’FINISHED REQUEST 009...’ TO SCREEN-MESSAGE.
            EXEC CICS SEND TEXT FROM(SCREEN-MESSAGE)
                 LENGTH(60) FREEKB ERASE
            END-EXEC.
        
        SQL-CODE-EXIT.
        
            EXIT.
        
        SQL-LOGOFF.
        
            MOVE ’SQL-LOGOFF’ TO P-PGPH-NAME.
        
            EXEC SQL LOGOFF END-EXEC.
        
            IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
        
            MOVE ’LOGGED OFF ...         ’ TO SCREEN-MESSAGE.
            EXEC CICS SEND TEXT FROM(SCREEN-MESSAGE)
                 LENGTH(60) FREEKB ERASE
            END-EXEC.
        
        SQL-LOGOFF-END.
        
            EXIT.
        
        THE-END.
        
            EXEC CICS RETURN
            END-EXEC.
            GOBACK.
        
        0200-COMMIT.
        
            MOVE ’0200-COMMIT’ TO P-PGPH-NAME.
        
            EXEC SQL COMMIT END-EXEC.
        
            IF SQLCODE NOT EQUAL 0 THEN
              PERFORM ERRCHECK.
        
        ERRCHECK.
        
            IF SQLCODE = 2588 THEN MOVE TRY-AGAIN TO P-CODE
        
            ELSE
                 IF SQLCODE = 100 THEN MOVE EOF TO P-CODE
        
            ELSE
                 IF SQLCODE = -601 THEN MOVE EOF TO P-CODE
        
            ELSE
                 MOVE P-PGPH-NAME TO PGPHNAME
                 MOVE SQLCODE TO ERRCODE.
        
            EXEC CICS SEND TEXT FROM(MESSAGE-OUT)
                       LENGTH(80) FREEKB ERASE
        
            END-EXEC.
        
        0200-COMMIT-END.
        
            EXIT.
   