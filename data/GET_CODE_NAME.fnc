
  CREATE OR REPLACE FUNCTION "CBSADM"."GET_CODE_NAME" (vi_code_group in varchar2, vi_code in varchar2, vi_language in varchar2)
   return varchar2 is
   /******************************************************************************
      NAME:       get_code_name
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        2018. 7. 6.   charles       1. Created this function.

      NOTES:
       vi_code_group : code group
       vi_language   : language

      Automatically available Auto Replace Keywords:
         Object Name:     get_code_name
         Sysdate:         2018. 7. 6.
         Date and Time:   2018. 7. 6., 14:23:02, and 2018. 7. 6. 14:23:02
         Username:        charles (set in TOAD Options, Procedure Editor)
         Table Name:       (set in the "New PL/SQL Object" dialog)

   ******************************************************************************/
   vs_code_name   ut_co_common_code.name%type;
   vs_language    ut_co_common_code.language%type;
begin
   vs_code_name := null;
   
   vs_language := vi_language;

   if vs_language is null then
      vs_language := 'en';
   end if;

   select name                                                          -- 코드명
     into vs_code_name
     from ut_co_common_code                                            -- 공통코드
    where code_group = vi_code_group                    -- 공통코드그룹 : BS공통여부
      and code       = vi_code
      and language   = vs_language;                       -- 적용언어코드 : en, mn

   return vs_code_name;
exception
   when no_data_found then
      return 'Unknown';
end get_code_name;