* @ValidationCode : MjoxNTE0MzY4NjAzOkNwMTI1MjoxNzQ4ODU0Njk3NDAxOnVzZXI6LTE6LTE6MDowOnRydWU6Ti9BOlIyMl9TUDQuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 02 Jun 2025 11:58:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : user
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : R22_SP4.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE EB.ALLINONE
*------------------------------------------------------------------------------

SUBROUTINE FRAUD.TXN.LIST.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine TELEBIRR.PARAM.FIELDS
*
* @author tcoleman@temenos.com
* @stereotype fields template
* @uses Table
* @public Table Creation
* @package infra.eb
* </doc>
*-----------------------------------------------------------------------------
* Modification History :
*
* 19/10/07 - EN_10003543
*            New Template changes
*
* 14/11/07 - BG_100015736
*            Exclude routines that are not released
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes
*** </region>
*-----------------------------------------------------------------------------
    ID.F = 'ID' ; ID.N = '6'
  
*-----------------------------------------------------------------------------
    fieldName = "DEBIT.CUS.ID"
    fieldLength = '50'
    fieldType='ANY'
    neighbour = ''
    CALL Table.addFieldDefinition(fieldName,fieldLength,fieldType,neighbour)
    fieldName = "CREDIT.CUS.ID"
    fieldLength = '50'
    fieldType='ANY'
    neighbour = ''
    CALL Table.addFieldDefinition(fieldName,fieldLength,fieldType,neighbour)
    fieldName = "CREDIT.ACCT"
    fieldLength = '50'
    fieldType='ANY'
    neighbour = ''
    CALL Table.addFieldDefinition(fieldName,fieldLength,fieldType,neighbour)
    
    fieldName = "CLIENT.IP"
    fieldLength = '50'
    fieldType='ANY'
    neighbour = ''
    CALL Table.addFieldDefinition(fieldName,fieldLength,fieldType,neighbour)
    
    
*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition ;* Poputale audit information
*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
