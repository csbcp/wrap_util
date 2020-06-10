
  CREATE OR REPLACE FUNCTION "CBSADM"."FUNC_PAYMENT_CNCL" (
   vi_pym_seqno         in number
 , vi_bill_acnt_id      in number
 , vi_bill_acnt_grp_id  in number
 , vi_pym_work_kd_cd    in varchar2
 , vi_pym_work_rsn_cd   in varchar2
 , vi_pym_cncl_amt      in number
 , vi_cncl_date         in varchar2
 , vi_operator_id       in varchar2)
   return varchar2 is
   /******************************************************************************
      NAME:        Payment(Payment.pc)
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
   vs_log_id   varchar2 (16);
   vs_log_type varchar2 (16);                                                                                                            -- ERROR, LOG
   vs_rtn_msg  varchar2 (1024); 
   vs_run_date varchar2(8);                                                                                                      -- return message

   vn_pym_blnc                   ut_ar_pym.pym_amt%type;
   vn_pym_srlno                  ut_ar_pym.srlno%type;
   vn_pym_blproc_srlno           ut_sb_bill_acnt.blproc_srlno%type;

   vn_cncl_rmnd_amt              number (15, 2) := 0;
   vn_cncl_trgt_amt              number (15, 2) := 0;
   vn_overpym_rmnd_amt           number (15, 2) := 0;

   vs_inv_rowid                  varchar2(30);
   vn_inv_balance                number(15, 2);
   vn_inv_bill_acnt_id           ut_ar_invs.bill_acnt_id%type;
   vn_inv_bill_acnt_grp_id       ut_ar_invs.bill_acnt_grp_id%type;
   vn_inv_chrg_amt               ut_ar_invs.chrg_amt%type;
   vn_inv_pym_amt                ut_ar_invs.pym_amt%type;
   vn_inv_adjmt_amt              ut_ar_invs.adjmt_amt%type;
   vn_inv_bltime_dscnt_amt       ut_ar_invs.bltime_dscnt_amt%type;
   vs_inv_chrg_cpay_yn           ut_ar_invs.chrg_cpay_yn%type;
   vs_inv_chrg_cpay_yn_chng_dt   ut_ar_invs.chrg_cpay_yn_chng_dt%type;      
   vs_inv_subs_id                ut_ar_invs.subs_id%type;
   
   vn_pym_seqno                  ut_ar_pym_ofst.seqno%type; 
   vs_ofst_prss_work_kd_cd       ut_ar_pym_ofst.ofst_prss_work_kd_cd%type;
   vn_ofst_prss_seqno            ut_ar_pym_ofst.ofst_prss_seqno%type;
   vn_ofst_prss_detl_srlno       ut_ar_pym_ofst.ofst_prss_detl_srlno%type;
   vn_ofst_amt                   ut_ar_pym_ofst.ofst_amt%type;
   vn_ofst_vat_amt               ut_ar_pym_ofst.ofst_vat_amt%type;
   vn_acnt_blnc                  ut_sb_bill_acnt.acnt_blnc%type;
   vn_sum_pym_cncl_amt           number(15, 2) := 0;
                
begin
   vs_log_id   := cbs_online_payment.gs_log_id;
   vs_log_type := cbs_online_payment.gs_log_type;
   vs_run_date := to_char (sysdate, 'yyyymmdd');

   begin
      select nvl (sum (pym_amt), 0)
           , nvl (max (srlno), 0)
        into vn_pym_blnc
           , vn_pym_srlno
        from ut_ar_pym
       where bill_acnt_id     = vi_bill_acnt_id
         and bill_acnt_grp_id = vi_bill_acnt_grp_id
         and pym_mgmt_seqno   = vi_pym_seqno;
   exception
      when others then
         vs_rtn_msg := 'sqlcode : [' || sqlcode || '], sqlerrm : [' || substr (sqlerrm, 1, 900) || ']' || dbms_utility.format_error_backtrace;
         return vs_rtn_msg;
   end;

   begin
      select blproc_srlno
        into vn_pym_blproc_srlno
        from ut_sb_bill_acnt
       where bill_acnt_id = vi_bill_acnt_id;
   exception
      when others then
         vs_rtn_msg := 'sqlcode : [' || sqlcode || '], sqlerrm : [' || substr (sqlerrm, 1, 900) || ']' || dbms_utility.format_error_backtrace;
         return vs_rtn_msg;
   end;
   
   begin
      insert into ut_ar_pym (bill_acnt_id
                           , seqno
                           , srlno
                           , bill_acnt_grp_id
                           , pym_mgmt_seqno
                           , lnkg_pym_seqno
                           , lnkg_pym_entr_detl_seqno
                           , subs_id
                           , aceno
                           , wdrw_dt
                           , rflct_dt
                           , rflct_dttm
                           , rcpmny_dt
                           , pym_amt
                           , cur_cd
                           , covrt_base_rto
                           , pym_covrt_amt
                           , ins_rflct_amt
                           , cust_rfnd_amt
                           , blproc_srlno
                           , pym_mthd_cd
                           , pym_mthd_detl_cd
                           , bank_cd
                           , acct_no
                           , card_no
                           , card_expr_yymm
                           , ppcrd_no
                           , pym_sorc_clss_cd
                           , pym_sorc_cd
                           , pym_work_kd_cd
                           , pym_work_rsn_cd
                           , file_prss_no
                           , pym_rsht_no
                           , pym_lvl_cd
                           , excp_prsn_cd
                           , created_at
                           , operator_id
                           , application_id)
         select bill_acnt_id
              , seqno
              , vn_pym_srlno + 1
              , bill_acnt_grp_id
              , pym_mgmt_seqno
              , lnkg_pym_seqno
              , lnkg_pym_entr_detl_seqno
              , subs_id
              , aceno
              , wdrw_dt
              , rflct_dt
              , sysdate
              , rcpmny_dt
              , pym_amt * -1
              , cur_cd
              , covrt_base_rto
              , pym_covrt_amt
              , pym_amt * -1
              , cust_rfnd_amt
              , blproc_srlno
              , pym_mthd_cd
              , pym_mthd_detl_cd
              , bank_cd
              , acct_no
              , card_no
              , card_expr_yymm
              , ppcrd_no
              , pym_sorc_clss_cd
              , pym_sorc_cd
              , vi_pym_work_kd_cd
              , vi_pym_work_rsn_cd
              , file_prss_no
              , pym_rsht_no
              , pym_lvl_cd
              , excp_prsn_cd
              , sysdate
              , vi_operator_id
              , 'Func_Payment_Cncl'
           from ut_ar_pym
          where bill_acnt_id     = vi_bill_acnt_id
            and bill_acnt_grp_id = vi_bill_acnt_grp_id
            and pym_mgmt_seqno   = vi_pym_seqno
            and srlno            = vn_pym_srlno;
   exception
      when others then
         vs_rtn_msg := 'sqlcode : [' || sqlcode || '], sqlerrm : [' || substr (sqlerrm, 1, 900) || ']' || dbms_utility.format_error_backtrace;
         return vs_rtn_msg;
   end;
            
   vn_cncl_rmnd_amt := vi_pym_cncl_amt;

   for rec in (
       select rowid
            , bill_acnt_id
            , seqno
            , bill_acnt_grp_id
            , ofst_amt
            , ofst_vat_amt
            , work_dv_cd
            , lnkg_pym_seqno
            , charge_seqno
            , ofst_prss_work_kd_cd
            , ofst_prss_seqno
            , ofst_prss_detl_srlno
            , ofst_cncl_work_kd_cd
            , ofst_cncl_seqno
            , ofst_cncl_detl_srlno
            , credt_occr_dt
            , spcify_chrg_aply_yn
            , aceno
            , work_lvl_cd
         from ut_ar_pym_ofst
        where bill_acnt_id         = vi_bill_acnt_id
          and bill_acnt_grp_id     = vi_bill_acnt_grp_id
          and lnkg_pym_seqno       = vi_pym_seqno
          and work_dv_cd           = '1'
          and ofst_cncl_work_kd_cd is null
          and ofst_cncl_seqno      is null
          and ofst_cncl_detl_srlno is null
        order by created_at desc
               , seqno desc
      )
   loop
      if vn_cncl_rmnd_amt >= rec.ofst_amt then
         vn_cncl_trgt_amt := rec.ofst_amt;
      else
         vn_cncl_trgt_amt := vn_cncl_rmnd_amt;
      end if; 

      if rec.charge_seqno > 0 then
        select rowid
             , bill_acnt_id
             , bill_acnt_grp_id
             , nvl(chrg_amt, 0)
             , nvl(pym_amt, 0) 
             , nvl(adjmt_amt, 0)
             , nvl(bltime_dscnt_amt, 0)
             , chrg_cpay_yn
             , chrg_cpay_yn_chng_dt
             , subs_id
          into vs_inv_rowid
             , vn_inv_bill_acnt_id
             , vn_inv_bill_acnt_grp_id
             , vn_inv_chrg_amt
             , vn_inv_pym_amt
             , vn_inv_adjmt_amt
             , vn_inv_bltime_dscnt_amt
             , vs_inv_chrg_cpay_yn
             , vs_inv_chrg_cpay_yn_chng_dt
             , vs_inv_subs_id
          from ut_ar_invs
         where bill_acnt_id     = vi_bill_acnt_id
           and bill_acnt_grp_id = mod(vi_bill_acnt_id, 10)
           and charge_seqno     = rec.charge_seqno;

         if vn_cncl_trgt_amt > vn_inv_pym_amt then
            return '[ERROR] invoice cancel requested amount cannot exceed invoice possible cancel amount\n';
         end if;
         
         vn_inv_pym_amt := vn_inv_pym_amt - vn_cncl_trgt_amt;
         vn_inv_balance := vn_inv_chrg_amt - (vn_inv_pym_amt
                                            + vn_inv_adjmt_amt
                                            + vn_inv_bltime_dscnt_amt);
         if vn_inv_balance < 0 then
            return 'Invoice balance cannot be negative';
         else
            if vs_inv_chrg_cpay_yn = '1' then
               vs_inv_chrg_cpay_yn_chng_dt := vs_run_date;
            end if;
            vs_inv_chrg_cpay_yn := '0'; 
         end if;
         
         update ut_ar_invs
            set pym_amt              = vn_inv_pym_amt
              , chrg_cpay_yn         = vs_inv_chrg_cpay_yn
              , chrg_cpay_yn_chng_dt = vs_inv_chrg_cpay_yn_chng_dt
              , chng_work_dt         = vs_run_date
              , application_id       = 'Func_Payment_Cncl'
              , operator_id          = vi_operator_id
              , updated_at           = sysdate
          where rowid  = vs_inv_rowid;
         
      end if;
         
      update ut_ar_pym_ofst
         set ofst_cncl_work_kd_cd = '2'
           , ofst_cncl_seqno      = vi_pym_seqno
           , ofst_cncl_detl_srlno = vn_pym_srlno
           , application_id       = 'Func_Payment_Cncl'
           , operator_id          = vi_operator_id
           , updated_at           = sysdate
       where rowid = rec.rowid;

      if vn_cncl_rmnd_amt < rec.ofst_amt then
         vn_overpym_rmnd_amt := rec.ofst_amt - vn_cncl_rmnd_amt;
         vs_ofst_prss_work_kd_cd := '2';
         vn_ofst_prss_seqno      := vi_pym_seqno;
         vn_ofst_prss_detl_srlno := vn_pym_blproc_srlno;
         vn_ofst_amt             := vn_overpym_rmnd_amt;
         if vn_ofst_vat_amt > 0 then
            vn_ofst_vat_amt := vn_ofst_vat_amt / 11;
         end if;

         insert into ut_ar_pym_ofst ( bill_acnt_id
                                    , seqno
                                    , bill_acnt_grp_id
                                    , ofst_amt
                                    , ofst_vat_amt
                                    , work_dv_cd
                                    , lnkg_pym_seqno
                                    , charge_seqno
                                    , ofst_prss_work_kd_cd
                                    , ofst_prss_seqno
                                    , ofst_prss_detl_srlno
                                    , credt_occr_dt
                                    , spcify_chrg_aply_yn
                                    , aceno
                                    , work_lvl_cd
                                    , created_at
                                    , application_id
                                    , operator_id)
              values (rec.bill_acnt_id
                    , sq_ar_pym_ofst.nextval
                    , rec.bill_acnt_grp_id
                    , vn_ofst_amt
                    , vn_ofst_vat_amt
                    , '2'
                    , rec.lnkg_pym_seqno
                    , rec.charge_seqno
                    , rec.ofst_prss_work_kd_cd
                    , rec.ofst_prss_seqno
                    , rec.ofst_prss_detl_srlno
                    , rec.credt_occr_dt
                    , rec.spcify_chrg_aply_yn
                    , rec.aceno
                    , '2'
                    , sysdate
                    , vi_operator_id
                    , 'Func_Payment_Cncl');
      end if;
      
      vn_cncl_rmnd_amt := vn_cncl_rmnd_amt - vn_cncl_trgt_amt;
      if vn_cncl_rmnd_amt <= 0 then
         exit;
      end if;
   end loop;

   select nvl(acnt_blnc,0)
     into vn_acnt_blnc
     from ut_sb_bill_acnt
    where bill_acnt_id = vi_bill_acnt_id;
    
   if vn_acnt_blnc < 0 then
      if cbs_billing.func_overpym_reapply(vi_bill_acnt_id
                         , vi_bill_acnt_grp_id
                         , vi_pym_seqno
                         , vn_pym_srlno
                         , '2') != '000' then
         return 'NOK';             
      end if;
   end if;
   vn_sum_pym_cncl_amt := vi_pym_cncl_amt;

   update ut_sb_bill_acnt
      set acnt_blnc       = nvl(acnt_blnc,0) + vn_sum_pym_cncl_amt
        , application_id  = 'Func_Payment_Cncl'
        , operator_id     = vi_operator_id
        , updated_at      = sysdate
    where bill_acnt_id    = vi_bill_acnt_id;
     
   return '000';
end func_payment_cncl;