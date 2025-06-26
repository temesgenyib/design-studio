* @ValidationCode : MjozNzA0NDM3NTA6Q3AxMjUyOjE3NDkwMzkyNDQ3OTk6dXNlcjotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMl9TUDQuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 04 Jun 2025 15:14:04
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
PROGRAM EXTRACT.FUNDS.TRANSFER
* Program to extract data from FUNDS.TRANSFER and generate ISO 20022 XML
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT
    $INCLUDE JBC.h
    CALL LOAD.COMPANY("ET0010001")
    
    FN.FUN="F.FUNDS.TRANSFER"
    F.FUN=""
    FN.ACC="F.ACCOUNT"
    F.ACC=""
    CALL OPF(FN.ACC,F.ACC)
    CALL OPF(FN.FUN,F.FUN)


* Get today's date in YYYY-MM-DD format
    TODAY = OCONV(DATE(), 'D-YMD[4,2,2]')
    NOW = TIME()
    HOURS = NOW[1,2]
    MINUTES = NOW[3,2]
    SECONDS = NOW[5,2]
    TIMESTAMP = TODAY:'T':HOURS:':':MINUTES:':':SECONDS:'+02:00'

* Create a unique message ID
    MSG.ID = "IQF":TODAY[3,2]:TODAY[5,2]:TODAY[7,2]:HOURS:MINUTES:SECONDS:"000000007098"

* Initialize XML variables
    XML.HEADER = '<?xml version="1.0" encoding="UTF-8"?>'
    XML.HEADER := '<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.005.001.02" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
    XML.HEADER := '<BlkChq>'

* Group Header - with placeholders that we'll replace later
    GRP.HDR = '<GrpHdr>'
    GRP.HDR := '<MsgId>':MSG.ID:'</MsgId>'
    GRP.HDR := '<CreDtTm>':TIMESTAMP:'</CreDtTm>'
    GRP.HDR := '<NbOfTxs>##TXCOUNT##</NbOfTxs>'
    GRP.HDR := '<TtlIntrBkSttlmAmt Ccy="ETB">##TOTALAMOUNT##</TtlIntrBkSttlmAmt>'
    GRP.HDR := '<IntrBkSttlmDt>':TODAY:'+02:00</IntrBkSttlmDt>'
    GRP.HDR := '<SttlmInf><SttlmMtd>CLRG</SttlmMtd><ClrSys><Prtry>ACH</Prtry></ClrSys></SttlmInf>'
    GRP.HDR := '<InstgAgt><FinInstnId><BIC>ABYSETAA</BIC></FinInstnId></InstgAgt>'
    GRP.HDR := '</GrpHdr>'

* Initialize transaction variables
    TX.COUNT = 0
    TOTAL.AMOUNT = 0
    CHEQUE.DETAILS = ''

* Select all FUNDS.TRANSFER records for today
 

* Check if this is a cheque transaction for today
    IF R.NEW(FT.TRANSACTION.TYPE)= 'ACCQ' AND R.NEW(FT.DEBIT.VALUE.DATE)[1,8] = TODAY THEN
* Extract relevant fields (field numbers may need adjustment)
        END.TO.END.ID = "12323243243434"
        TX.ID = ID.NEW
        AMOUNT = R.NEW(FT.DEBIT.AMOUNT)
        CURRENCY = R.NEW(FT.CURRENCY)
        DR.ACC=R.NEW(FT.DEBIT.ACCT.NO)
        CALL F.READ(FN.ACC,DR.ACC,ACC.REC,F.ACC,ACC.ERR)
            
        DEBTOR.NAME = ACC.REC<AC.ACCOUNT.TITLE.1>
        DEBTOR.ACCT = DR.ACC
        DEBTOR.BANK = "ABYSETAA"
        CR.ACC=R.NEW(FT.CREDIT.ACCT.NO)
        CALL F.READ(FN.ACC,CR.ACC,CR.REC,F.ACC,CR.ERR)
        CREDITOR.NAME = CR.REC<AC.ACCOUNT.TITLE.1>
        CREDITOR.ACCT = CR.ACC
        CREDITOR.BANK = "COOP"
            
* Build Cheque details
        CHEQUE.XML = '<Chq>'
        CHEQUE.XML := '<PmtId>'
        CHEQUE.XML := '<EndToEndId>':END.TO.END.ID:'</EndToEndId>'
        CHEQUE.XML := '<TxId>':TX.ID:'</TxId>'
        CHEQUE.XML := '</PmtId>'
        CHEQUE.XML := '<PmtTpInf>'
        CHEQUE.XML := '<SvcLvl><Cd>SEPA</Cd></SvcLvl>'
        CHEQUE.XML := '<LclInstrm><Cd>CORE</Cd></LclInstrm>'
        CHEQUE.XML := '</PmtTpInf>'
        CHEQUE.XML := '<IntrBkSttlmAmt Ccy="':CURRENCY:'">':AMOUNT:'</IntrBkSttlmAmt>'
        CHEQUE.XML := '<ChrgBr>SLEV</ChrgBr>'
        CHEQUE.XML := '<ChequeTx>'
        CHEQUE.XML := '<ChkNmbr>':END.TO.END.ID:'</ChkNmbr>'
        CHEQUE.XML := '<AccNo>':DEBTOR.ACCT:'</AccNo>'
        CHEQUE.XML := '<Microcode>NO_MICROCODE</Microcode>'
        CHEQUE.XML := '<BankCode>':DEBTOR.BANK[1,3]:'</BankCode>'
        CHEQUE.XML := '<BranchCode>':DEBTOR.BANK[4,4]:'</BranchCode>'
        CHEQUE.XML := '</ChequeTx>'
        CHEQUE.XML := '<Cdtr><Nm>':CREDITOR.NAME:'</Nm></Cdtr>'
        CHEQUE.XML := '<CdtrAcct><Id><IBAN>':CREDITOR.ACCT:'</IBAN></Id></CdtrAcct>'
        CHEQUE.XML := '<CdtrAgt><FinInstnId><BIC>':CREDITOR.BANK:'</BIC></FinInstnId></CdtrAgt>'
        CHEQUE.XML := '<Dbtr><Nm>':DEBTOR.NAME:'</Nm>'
        CHEQUE.XML := '<Id><OrgId><BICOrBEI>':DEBTOR.BANK:'</BICOrBEI></OrgId></Id>'
        CHEQUE.XML := '</Dbtr>'
        CHEQUE.XML := '<DbtrAcct><Id><IBAN>':DEBTOR.ACCT:'</IBAN></Id></DbtrAcct>'
        CHEQUE.XML := '<DbtrAgt><FinInstnId><BIC>':DEBTOR.BANK:'</BIC></FinInstnId></DbtrAgt>'
        CHEQUE.XML := '</Chq>'
            
        PRINT CHEQUE.XML
        CHEQUE.DETAILS := CHEQUE.XML
        TX.COUNT += 1
        TOTAL.AMOUNT += AMOUNT
    END


* Replace placeholders in group header
* Using string manipulation instead of REPLACE function
    POS = INDEX(GRP.HDR, '##TXCOUNT##', 1)
    IF POS THEN
        GRP.HDR = GRP.HDR[1,POS-1]:TX.COUNT:GRP.HDR[POS+10,9999]
    END
    
    POS = INDEX(GRP.HDR, '##TOTALAMOUNT##', 1)
    IF POS THEN
        GRP.HDR = GRP.HDR[1,POS-1]:TOTAL.AMOUNT:GRP.HDR[POS+15,9999]
    END

* Combine all XML parts
    FULL.XML = XML.HEADER
    FULL.XML := GRP.HDR
    FULL.XML := CHEQUE.DETAILS
    FULL.XML := '</BlkChq>'
    FULL.XML := '</Document>'

* Write to output file
    OUTPUT.FILE = "FUNDS.TRANSFER.":TODAY:".xml"
    OPENSEQ OUTPUT.FILE TO FILE.HANDLE ELSE
        CRT "Unable to open output file ":OUTPUT.FILE
        STOP
    END
    WRITESEQ FULL.XML ON FILE.HANDLE ELSE
        CRT "Error writing to output file"
    END
    CLOSESEQ FILE.HANDLE

    CRT "XML file generated successfully: ":OUTPUT.FILE
END

