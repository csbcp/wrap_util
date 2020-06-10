
  CREATE OR REPLACE FUNCTION "CBSADM"."GET_PROD_KD_CD" (vi_subs_id in varchar2)
   return varchar2 is
   /******************************************************************************
      NAME:       get_main_prod
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        2018. 9. 7.   charles       1. Created this function.

      NOTES:

      Automatically available Auto Replace Keywords:
         Object Name:     get_main_prod
         Sysdate:         2018. 9. 7.
         Date and Time:   2018. 9. 7., 16:51:31, and 2018. 9. 7. 16:51:31
         Username:        charles (set in TOAD Options, Procedure Editor)
         Table Name:       (set in the "New PL/SQL Object" dialog)

   ******************************************************************************/
   vs_prod_kd_cd   ut_sb_subs_prod.prod_kd_cd%type;
begin
   select prod_kd_cd
     into vs_prod_kd_cd
     from ut_sb_subs_prod
    where subs_id = vi_subs_id;
   return vs_prod_kd_cd;
exception
   when no_data_found then
      vs_prod_kd_cd := '*';
   when others then
      -- Consider logging the error and then re-raise
      raise;
end get_prod_kd_cd;