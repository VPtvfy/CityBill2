CREATE OR REPLACE PROCEDURE new_month IS
  partname    varchar2(7);
  newpartname varchar2(7);
  newtablespace varchar2(8);
BEGIN

  partname    := 'P200710';

  SELECT 'P' || TO_CHAR(ADD_MONTHS(TO_DATE(SUBSTR(:partname,2),'YYYYMM'),2),'YYYYMM') INTO newpartname FROM dual;
  SELECT 'CITY' || TO_CHAR(TO_DATE(SUBSTR(:newpartname,2),'YYYYMM'),'YYYY') INTO newtablespace FROM dual;

  ALTER TABLE call_tplak ADD PARTITION :newpartname VALUES LESS THAN (ADD_MONTHS(TO_DATE(SUBSTR(:newpartname,2),'YYYYMM'),1)))
    TABLESPACE :newtablespace
    NOCOMPRESS;

--  TRUNCATE TABLE temp_tplak;
--  INSERT INTO temp_tplak SELECT * FROM call_tplak PARTITION (p200711);
--  DELETE FROM call_tplak WHERE 
--  INSERT /*+ APPEND */ INTO call_tplak SELECT * FROM temp_tplak ORDER BY caller,peer;

--  ALTER TABLE call_s12v5 ADD PARTITION P200801 VALUES LESS THAN (TO_DATE('2008-02-01 00:00:00','YYYY-MM-DD HH24:MI:SS'))
--    TABLESPACE CITY2008
--    NOCOMPRESS;

--  TRUNCATE TABLE temp_s12v5;
--  INSERT INTO temp_s12v5 SELECT * FROM call_s12v5 PARTITION (p200711);
--  DELETE FROM call_s12v5 WHERE 
--  INSERT /*+ APPEND */ INTO call_s12v5 SELECT * FROM temp_s12v5 ORDER BY bearer, calltype, abontype, recindicator, pulses, caller, peer;

--  ALTER TABLE call_s12v7 ADD PARTITION P200801 VALUES LESS THAN (TO_DATE('2008-02-01 00:00:00','YYYY-MM-DD HH24:MI:SS'))
--    TABLESPACE CITY2008
--    NOCOMPRESS;

--  TRUNCATE TABLE temp_s12v7;
--  INSERT INTO temp_s12v7 SELECT * FROM call_s12v7 PARTITION (p200711);
--  DELETE FROM call_s12v7 WHERE 
--  INSERT /*+ APPEND */ INTO call_s12v7 SELECT * FROM temp_s12v7 ORDER BY bearer, midnightwalk, calltype, recindicator, abontype,trunk_in, trunk_out, caller, peer;

--  COMMIT;
END;

execute new_month;