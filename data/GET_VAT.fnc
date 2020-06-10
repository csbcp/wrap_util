
  CREATE OR REPLACE FUNCTION "CBSADM"."GET_VAT" (vi_amount in number)return number is
/******************************************************************************
   NAME:       get_vat
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2019. 5. 23.   charles       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     get_vat
      Sysdate:         2019. 5. 23.
      Date and Time:   2019. 5. 23., 17:41:12, and 2019. 5. 23. 17:41:12
      Username:        charles (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
begin
   return round((vi_amount  / 1.1) * 0.1 , 2);
   exception
     when others then
       -- Consider logging the error and then re-raise
       raise;
end get_vat;