
  CREATE OR REPLACE FUNCTION "CBSADM"."GET_INV_CUST_TAX" (vi_cust_id in number, vi_cust_chng_dt in date) return varchar2 is
/******************************************************************************
   NAME:       get_cust_tax
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2019. 2. 18.   charles       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     get_cust_tax
      Sysdate:         2019. 2. 18.
      Date and Time:   2019. 2. 18., 10:40:31, and 2019. 2. 18. 10:40:31
      Username:        charles (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
   vs_tax_inc  varchar2(5);
begin
   -- search by customer
   -- search by subscriber
   -- search by bill account
   begin
      select tax_inc
        into vs_tax_inc
        from ut_sb_cust_hist a
       where cust_hist_id = ( select max(cust_hist_id)
                                from ut_sb_cust_hist a
                               where cust_id       = vi_cust_id
                                 and cust_chng_dt <= cust_chng_dt);
   exception
      when others then
         vs_tax_inc := '1';
   end;
   
   return vs_tax_inc;
end get_inv_cust_tax;