
  CREATE OR REPLACE FUNCTION "CBSADM"."GET_INV_STEP_CNT" (vi_blwk_step in varchar2, vi_bill_trgt_yymm in varchar2, vi_bill_cycl_cd in number, vi_bill_work_seqno in number) return number is
tmpvar number;
/******************************************************************************
   NAME:       get_inv_step_cnt
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2019. 1. 24.   charles       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     get_inv_step_cnt
      Sysdate:         2019. 1. 24.
      Date and Time:   2019. 1. 24., 16:49:53, and 2019. 1. 24. 16:49:53
      Username:        charles (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
   vn_cnt   number(10);
begin
   -- list of bill Subscription
   if vi_blwk_step = '11' then
      select count(*) 
        into vn_cnt
        from ut_bs_blwkno_entr
       where bill_trgt_yymm    = vi_bill_trgt_yymm
         and bill_cycl_cd      = vi_bill_cycl_cd
         and bill_work_seqno   = vi_bill_work_seqno
         and data_prss_stts_cd = 'F';
   -- usage summary creation
   elsif vi_blwk_step = '12' then
      select count(*) 
        into vn_cnt
        from ut_bs_blwkno_entr
       where bill_trgt_yymm    = vi_bill_trgt_yymm
         and bill_cycl_cd      = vi_bill_cycl_cd
         and bill_work_seqno   = vi_bill_work_seqno
         and rtng_ttzn_stts_cd = 'F';
   -- list of bill account
   elsif vi_blwk_step = '13' then
      select count(*) 
        into vn_cnt
        from ut_bs_bill_trgt 
       where bill_trgt_yymm  = vi_bill_trgt_yymm
         and bill_acnt_id in (select bill_acnt_id
                                from ut_bs_blwkno_entr
                               where bill_trgt_yymm  = vi_bill_trgt_yymm
                                 and bill_cycl_cd    = vi_bill_cycl_cd
                                 and bill_work_seqno = vi_bill_work_seqno);
   -- usage fee calculation
   elsif vi_blwk_step = '14' then
      vn_cnt := 0;
   -- usage fee calculation
   elsif vi_blwk_step = '15' then
      select count(*) 
        into vn_cnt
        from ut_bs_blwkno_entr
       where bill_trgt_yymm    = vi_bill_trgt_yymm
         and bill_cycl_cd      = vi_bill_cycl_cd
         and bill_work_seqno   = vi_bill_work_seqno
         and ufee_ttzn_stts_cd = 'F';
   -- Recurring Calculation
   elsif vi_blwk_step = '16' then
      select count(*) 
        into vn_cnt
        from ut_bs_blwkno_entr
       where bill_trgt_yymm    = vi_bill_trgt_yymm
         and bill_cycl_cd      = vi_bill_cycl_cd
         and bill_work_seqno   = vi_bill_work_seqno
         and basf_ttzn_stts_cd = 'F';
   -- onetime charge calculation
   elsif vi_blwk_step = '17' then
      select count(*) 
        into vn_cnt
        from ut_bs_blwkno_entr
       where bill_trgt_yymm    = vi_bill_trgt_yymm
         and bill_cycl_cd      = vi_bill_cycl_cd
         and bill_work_seqno   = vi_bill_work_seqno
         and otfee_ttzn_stts_cd = 'F';
--    discount generation
   elsif vi_blwk_step = '18' then
      select count(*) 
        into vn_cnt
        from ut_bs_blwkno_entr
       where bill_trgt_yymm     = vi_bill_trgt_yymm
         and bill_cycl_cd       = vi_bill_cycl_cd
         and bill_work_seqno    = vi_bill_work_seqno
         and dscnt_calc_stts_cd = 'F';
--    bill creation
   elsif vi_blwk_step = '20' then
      vn_cnt := 0;
--    bill confirm
   elsif vi_blwk_step = '22' then
      select count(*) 
        into vn_cnt
        from ( select bill_acnt_id
                 from ut_ar_invs
                where bill_trgt_yymm = vi_bill_trgt_yymm
                group by bill_acnt_id
             );
   end if;
   
   return vn_cnt;
end get_inv_step_cnt;