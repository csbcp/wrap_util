
  CREATE OR REPLACE FUNCTION "CBSADM"."GET_TAX_AMT" (vi_bill_acnt in number, vi_charge_amt in number) return number is
/******************************************************************************
   NAME:       get_tax_amt
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2019. 3. 8.   charles       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     get_tax_amt
      Sysdate:         2019. 3. 8.
      Date and Time:   2019. 3. 8., 09:43:20, and 2019. 3. 8. 09:43:20
      Username:        charles (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
   vn_tax   number(12, 2);
begin
   if get_cust_tax (vi_bill_acnt) = '1' then
      vn_tax := round((vi_charge_amt / 1.1) * 0.1 , 2);
   else
      vn_tax := 0;
   end if;

   return vn_tax;
   exception
     when no_data_found then
       null;
     when others then
       -- Consider logging the error and then re-raise
       RAISE;
END get_tax_amt;