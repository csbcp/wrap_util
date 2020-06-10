
  CREATE OR REPLACE FUNCTION "CBSADM"."GET_BEGIN_BLNC" ( vi_bill_acnt_id   in number
                                                 , vi_cust_id        in number
                                                 , vi_subs_id        in number
                                                 , vi_bill_trgt_yymm in varchar2 ) return number is
/******************************************************************************
   NAME:       get_begin_blnc
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2019. 4. 22.   charles       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     get_begin_blnc
      Sysdate:         2019. 4. 22.
      Date and Time:   2019. 4. 22., 15:23:43, and 2019. 4. 22. 15:23:43
      Username:        charles (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/     
   vn_begin_blnc  number(13, 2);
begin
      select sum(( s1.chrg_amt + s1.unpaid_amt )
               + ( s1.adjmt_amt ) 
               - ( s1.pym_amt + s1.over_pym + s1.pym_dscnt_amt )
                ) as begin_blan
        into vn_begin_blnc
        from ut_ar_invs s1
       where s1.bill_acnt_id   = vi_bill_acnt_id
         and s1.cust_id        like vi_cust_id||'%'
         and s1.subs_id        like vi_subs_id||'%'
         and s1.bill_trgt_yymm = to_char(add_months(to_date(vi_bill_trgt_yymm, 'yymm'), -1), 'yyyymm');

      return nvl(vn_begin_blnc, 0);
   exception
     when others then
       return  0;
end get_begin_blnc;