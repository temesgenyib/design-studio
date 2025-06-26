* @ValidationCode : MjoxMTY2NjgwNzQ3OkNwMTI1MjoxNzQ4ODcyMTgzNTA4OnVzZXI6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjJfU1A0LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 02 Jun 2025 16:49:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R22_SP4.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE EB.ALLINONE
SUBROUTINE FRAUD.MGT
*-----------------------------------------------------------------------------
* Routine to update customer fraud detection records with IP tracking
*-----------------------------------------------------------------------------
* Input: ID.NEW (Customer ID being processed)
* Output: Updates PROTOCOL file with access details
*-----------------------------------------------------------------------------
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.CUSTOMER
    $INSERT I_F.USER
    $INSERT I_F.PROTOCOL
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.FRAUD.TXN.LIST

    GOSUB INIT
    GOSUB OPENFILE
    GOSUB PROCESS
RETURN
INIT:
    FN.CUS = "F.CUSTOMER"
    F.CUS = ""
    FN.SL="/u01/T24/t24sit/bnk/TEM.BP"
    F.SL=""
    FN.USER="F.USER"
    F.USER=""
    FN.PR="F.PROTOCOL"
    F.PR=""
    FN.FUN="F.FUNDS.TRANSFER"
    F.FUN=""
    FN.ACC="F.ACCOUNT"
    F.ACC=""
    FN.LOG="F.FRAUD.TXN.LIST"
    F.LOG=""
   
   
RETURN

*----- File Opening -----
OPENFILE:
* Initialize file variables
    CALL OPF(FN.CUS, F.CUS)
    CALL OPF(FN.SL,F.SL)
    CALL OPF(FN.USER,F.USER)
    CALL OPF(FN.PR,F.PR)
    CALL OPF(FN.FUN,F.FUN)
    CALL OPF(FN.ACC,F.ACC)
    CALL OPF(FN.LOG,F.LOG)
RETURN

*----- Main Processing -----
PROCESS:
    
    IF APPLICATION EQ "CUSTOMER" THEN
        CHANNELID = "T24"
        DAT = TIMESTAMP()
        CONVERTED.TS = OCONV(DAT, 'D4YMD[4,2,2]') : ' ' : OCONV(DAT, 'MTS')
        CALL F.READ(FN.CUS,ID.NEW,CUS.REC,F.CUS,CUS.ERR)
        CUS.NAME=CUS.REC<EB.CUS.SHORT.NAME>
        SMD ="SELECT F.PROTOCOL WITH ID EQ ":ID.NEW
        CALL EB.READLIST(SMD,PRT.LIST,'',NO.REC,RET.CODE)
        LOOP
            REMOVE PRT.ID FROM PRT.LIST SETTING POS
        WHILE PRT.ID
            CALL F.READ(FN.PR,PRT.ID,PRT.REC,F.PR,PR.ERR)
            CLIENTID=PRT.REC<EB.PTL.CLIENT.IP.ADDRESS>
            
            IF CLIENTID NE "" THEN
                BREAK
            END
        REPEAT
            
        IF CUS.REC THEN
            CUS.ID = ID.NEW
            CHANNEL.ID = "T24"
            EMPLOYEEOID = OPERATOR
            CALL F.READ(FN.USER,EMPLOYEEOID,USER.REC,F.USER,USER.ERR)
            EMPLOYEEOID=USER.REC<EB.USE.USER.NAME>
            CUSTOMERID = CUS.ID
            IP.ADDRESS=""
            Y.MS = CUSTOMERID:"*":EMPLOYEEOID:"*":CONVERTED.TS:"*":IP.ADDRESS:"*":CHANNELID
            CALLJ 'transngnew.TransNGNew', 'sendDetail', Y.MS  SETTING returnVal ON ERROR GOSUB ERROR.LIST
            VAL.RET.CODE = FIELD(returnVal,'@FM',1)

            IF VAL.RET.CODE EQ "200" THEN
                violation = FIELD(returnVal,'@FM',2)
                SCORE=violation

                CALL F.READ(FN.LOG,ID.NEW,LOG.REC,F.LOG,LOG.ERR)

                LOG.REC<BOA.BL.DESCRIPTION>=SCORE
                CALL F.WRITE(FN.LOG,ID.NEW,LOG.REC)
*CALL JOURNAL.UPDATE(ID.NEW)
*     IF SCORE EQ "hold"  THEN
                xmlRequest1 =xmlRequest
                Y.OVE.ID='FRUED.EXISTING'

                CURR.NO = DCOUNT(R.NEW(FT.OVERRIDE),@VM)+1
                TEXT = Y.OVE.ID
                CALL STORE.OVERRIDE(CURR.NO)
            END
            DATA.IN<-1>=ID.NEW:'|':SCORE

            WRITE DATA.IN TO F.SL,ID.NEW
        END

    END
    ELSE
        CHANNELID = "T24"
        DAT = TIMESTAMP()
        CONVERTED.TS = OCONV(DAT, 'D4YMD[4,2,2]') : ' ' : OCONV(DAT, 'MTS')
        SETTLEMENTAMOUNT=R.NEW(FT.DEBIT.AMOUNT)
        SETTLEMENTCURRENCY=R.NEW(FT.DEBIT.CURRENCY)
        DEBITPARTYACCOUNT=R.NEW(FT.DEBIT.ACCT.NO)
        CREDITPARTYACCOUNT=R.NEW(FT.CREDIT.ACCT.NO)
        CALL F.READ(FN.ACC,CREDITPARTYACCOUNT,CR.REC,F.ACC,CR.ERR)
        CREDITPARTYNAME=CR.REC<AC.ACCOUNT.TITLE.1>
        CALL F.READ(FN.ACC,DEBITPARTYACCOUNT,DR.REC,F.ACC,DR.ERR)
        DEBITPARTYNAME=DR.REC<AC.ACCOUNT.TITLE.1>
        CUSTOMERID=DR.REC<AC.CUSTOMER>
        ACCOUNTBALANCE=DR.REC<AC.WORKING.BALANCE>
        ACCOUNTCURRENCY=DR.REC<AC.CURRENCY>
        EMPLOYEEID=OPERATOR
        
        SCHEME=R.NEW<FT.TRANSACTION.TYPE>
        
        IF SETTLEMENTAMOUNT EQ "" THEN
            SETTLEMENTAMOUNT=R.NEW(FT.CREDIT.AMOUNT)
        END
        
        CUS.NAME=CUS.REC<EB.CUS.SHORT.NAME>
        SMD ="SELECT F.PROTOCOL WITH ID EQ ":ID.NEW
        CALL EB.READLIST(SMD,PRT.LIST,'',NO.REC,RET.CODE)
        LOOP
            REMOVE PRT.ID FROM PRT.LIST SETTING POS
        WHILE PRT.ID
            CALL F.READ(FN.PR,PRT.ID,PRT.REC,F.PR,PR.ERR)
            EMPLOYEEIPADDR=PRT.REC<EB.PTL.CLIENT.IP.ADDRESS>
            
            IF EMPLOYEEIPADDR NE "" THEN
                BREAK
            END
        REPEAT
        Y.MS = CUSTOMERID:"@FM":EMPLOYEEID:"@FM":CONVERTED.TS:"@FM":EMPLOYEEIPADDR:"@FM":CHANNELID:"@FM":SETTLEMENTAMOUNT:"@FM":SETTLEMENTCURRENCY:"@FM":DEBITPARTYACCOUNT:"@FM":CREDITPARTYACCOUNT:"@FM":CREDITPARTYNAME:"@FM":DEBITPARTYNAME:"@FM":ACCOUNTBALANCE:"@FM":ACCOUNTCURRENCY:"@FM":SCHEME
        CALLJ 'transngnew.TransNGNew', 'sendDetail', Y.MS  SETTING returnVal ON ERROR GOSUB ERROR.LIST
        VAL.RET.CODE = FIELD(returnVal,'@FM',1)

        IF VAL.RET.CODE EQ "200" THEN
            violation = FIELD(returnVal,'@FM',2)
            SCORE=violation

            CALL F.READ(FN.LOG,ID.NEW,LOG.REC,F.LOG,LOG.ERR)

            LOG.REC<BOA.BL.DESCRIPTION>=SCORE
            CALL F.WRITE(FN.LOG,ID.NEW,LOG.REC)
*CALL JOURNAL.UPDATE(ID.NEW)
*     IF SCORE EQ "hold"  THEN
            xmlRequest1 =xmlRequest
            Y.OVE.ID='FRUED.EXISTING'

            CURR.NO = DCOUNT(R.NEW(FT.OVERRIDE),@VM)+1
            TEXT = Y.OVE.ID
            CALL STORE.OVERRIDE(CURR.NO)
        END
        DATA.IN<-1>=ID.NEW:'|':SCORE

        WRITE DATA.IN TO F.SL,ID.NEW

*     END

    END
END
        
RETURN