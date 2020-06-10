
  CREATE OR REPLACE FUNCTION "CBSADM"."GET_BLITEM_NM" (vi_domain in varchar2, vi_blitem_cd in varchar2)
   return varchar2 is
/******************************************************************************
   NAME:       get_blitem_nm
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2018. 11. 26.   charles       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     get_blitem_nm
      Sysdate:         2018. 11. 26.
      Date and Time:   2018. 11. 26., 15:08:36, and 2018. 11. 26. 15:08:36
      Username:        charles (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
   vs_blitem_nm   ut_bs_blitem.blitem_nm%type;
begin
   select blitem_nm
     into vs_blitem_nm
     from ut_bs_blitem
    where domain = vi_domain
      and blitem_cd = vi_blitem_cd;

   return vs_blitem_nm;
exception
   when no_data_found then
      return '*';
   when others then
      -- Consider logging the error and then re-raise
      raise;
end get_blitem_nm;