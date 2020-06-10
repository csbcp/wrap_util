
  CREATE OR REPLACE FUNCTION "CBSADM"."FUNC_PYM_JOURNALING" (vi_lnkg_pym_seqno in number ) return varchar2 is
/******************************************************************************
   NAME:        func_pym_journaling(Payment.pc)     
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2018-12-26   charles       1. Created this function.
   TABLE                                                              CRUD     
   =========================================================================== 
   UT_BS_BILL_TRGT                                                    RU       

   Date       Author   Description                                             
   ========== ======== ========================================================

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     a
      Sysdate:         2018-12-26
      Date and Time:   2018-12-26, 17:51:50, and 2018-12-26 17:51:50
      Username:        charles (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
begin
   return '000';
end func_pym_journaling;