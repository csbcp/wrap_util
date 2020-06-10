
  CREATE OR REPLACE FUNCTION "CBSADM"."GET_VALUE" (vi_first in number, vi_second in number) return number is
  vn_third  number(15, 2);
begin
   begin
      vn_third := vi_first / vi_second;
   
      return vn_third;
   exception
     when no_data_found then
       null;
     when others then
       dbms_output.put_line('ERROR');
  end;
end get_value;