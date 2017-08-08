-- Create main schema
create user CB
  identified by "&cbpwd"
  default tablespace USERS
  temporary tablespace TEMP
  profile DEFAULT;
grant connect to CB;
grant unlimited tablespace to CB;

-- Create tablespaces
CREATE TABLESPACE "CITYFILES" 
    LOGGING 
    DATAFILE 'D:\ORACLE\ORADATA\CITYFILES.DBF' SIZE 16M
    REUSE AUTOEXTEND 
    ON NEXT 2M MAXSIZE  4000M EXTENT MANAGEMENT LOCAL SEGMENT 
    SPACE MANAGEMENT AUTO;

CREATE TABLESPACE "CITY_TMP" 
    LOGGING DATAFILE
    'D:\ORACLE\ORADATA\CITY_TMP01.DBF' SIZE 4M REUSE AUTOEXTEND 
    ON NEXT  4096K MAXSIZE  4000M, 
    'D:\ORACLE\ORADATA\CITY_TMP02.DBF' SIZE 4M REUSE AUTOEXTEND 
    ON NEXT  4096K MAXSIZE  4000M, 
    'D:\ORACLE\ORADATA\CITY_TMP03.DBF' SIZE 4M REUSE AUTOEXTEND 
    ON NEXT  4096K MAXSIZE  4000M EXTENT MANAGEMENT LOCAL SEGMENT 
    SPACE MANAGEMENT AUTO;

-- Main tables
create table CB.CALL_DAMA
(
  FILE_ID  NUMBER(11) not null,
  CALLER   VARCHAR2(20),
  PEER     VARCHAR2(30),
  CALLTIME DATE,
  DURATION NUMBER(6),
  X31      VARCHAR2(20),
  X32      VARCHAR2(20),
  X33      VARCHAR2(20),
  X34      VARCHAR2(20),
  X35      VARCHAR2(20),
  X36      VARCHAR2(8),
  X37      VARCHAR2(8),
  X38      VARCHAR2(8)
)
tablespace CITY_TMP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  )
;
alter table CB.CALL_DAMA
  add constraint CALL_DAMA_FK foreign key (FILE_ID)
  references CB.FILES (ID);

create table CB.CALL_OVERSEA
(
  FILE_ID      NUMBER(11) not null,
  SN           NUMBER(9),
  TICKETTYPE   VARCHAR2(2),
  CALLATTEMPT  NUMBER(1),
  CENTERCHARGE NUMBER(1),
  PPS          NUMBER(1),
  CHARGEMETHOD NUMBER(1),
  NPCALL       NUMBER(1),
  PAYER        NUMBER(2),
  CHARGINGDNS  NUMBER(3),
  CHARGING     VARCHAR2(20),
  CALLERDNS    NUMBER(3),
  CONNECTEDDNS NUMBER(3),
  CONNECTED    VARCHAR2(20),
  PEERDNS      NUMBER(3),
  DEALED       VARCHAR2(24),
  CNXGROUP     NUMBER(5),
  CCNXNUM      NUMBER(4),
  PCNXGROUP    NUMBER(4),
  CMODNUMBER   NUMBER(4),
  PMODNUMBER   NUMBER(4),
  TRUNK_IN     VARCHAR2(4),
  TRUNK_OUT    VARCHAR2(4),
  SUBROUTE_IN  VARCHAR2(4),
  SUBROUTE_OUT VARCHAR2(4),
  CDTYPE       NUMBER(3),
  PDTYPE       NUMBER(3),
  CPNUM        VARCHAR2(4),
  PPNUM        VARCHAR2(4),
  CCAT         NUMBER(3),
  PCAT         NUMBER(3),
  CALLTYPE     VARCHAR2(1),
  SRVTYPE      VARCHAR2(1),
  SUPPSRVTYPE  NUMBER(3),
  BALANCE      NUMBER(5),
  CALLER       VARCHAR2(18),
  PEER         VARCHAR2(25),
  CALLTIME     DATE,
  DURATION     NUMBER(6),
  PULSES       NUMBER(15),
  MIDNIGHTWALK NUMBER(1),
  FREEFLAG     NUMBER(1),
  RECINDICATOR NUMBER(1),
  BEARER       NUMBER(3)
)
tablespace CITY_TMP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  )
;
alter table CB.CALL_OVERSEA
  add constraint CALL_OVERSEA_FK foreign key (FILE_ID)
  references CB.FILES (ID);

create table CB.CALL_S12V5
(
  FILE_ID      NUMBER(11) not null,
  CALLER       VARCHAR2(18),
  PEER         VARCHAR2(25),
  CALLTIME     DATE,
  DURATION     NUMBER(6),
  CALLTYPE     NUMBER(1),
  ABONTYPE     NUMBER(1),
  PULSES       NUMBER(4),
  RECINDICATOR NUMBER(1),
  BEARER       NUMBER(1)
)
tablespace CITY_TMP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  )
;
alter table CB.CALL_S12V5
  add constraint CALL_S12V5_FK foreign key (FILE_ID)
  references CB.FILES (ID);

create table CB.CALL_S12V7
(
  FILE_ID      NUMBER(11) not null,
  TRUNK_IN     VARCHAR2(4),
  TRUNK_OUT    VARCHAR2(4),
  CALLER       VARCHAR2(18),
  PEER         VARCHAR2(25),
  CALLTIME     DATE,
  DURATION     NUMBER(6),
  CALLTYPE     NUMBER(1),
  ABONTYPE     NUMBER(3),
  PULSES       NUMBER(6),
  CONNTYPE     NUMBER(2),
  RECS         NUMBER(2),
  MIDNIGHTWALK NUMBER(1),
  RECINDICATOR NUMBER(1),
  BEARER       NUMBER(1)
)
tablespace CITY_TMP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  )
;
alter table CB.CALL_S12V7
  add constraint CALL_S12V7_FK foreign key (FILE_ID)
  references CB.FILES (ID);

create table CB.CALL_S12WR1A
(
  FILE_ID           NUMBER(11) not null,
  TRUNK_IN          VARCHAR2(15),
  TRUNK_OUT         VARCHAR2(15),
  CALLER            VARCHAR2(18),
  PEER              VARCHAR2(25),
  CALLTIME          DATE,
  DURATION          NUMBER(6),
  RECEIVEDDIGITS    NUMBER(15),
  ABONTYPE          NUMBER(3),
  BEARER            NUMBER(1),
  CALLID            VARCHAR2(4),
  RECTYPE           VARCHAR2(25),
  REDIRECTINGNUM    VARCHAR2(25),
  REDIRECTIONNUM    VARCHAR2(25),
  ORIGINALCALLEDNUM VARCHAR2(25),
  SERVICEUSER       NUMBER(3)
)
tablespace CITY_TMP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  )
;
alter table CB.CALL_S12WR1A
  add constraint CALL_S12WR1A_FK foreign key (FILE_ID)
  references CB.FILES (ID);

create table CB.CALL_TPLAK
(
  FILE_ID  NUMBER(11) not null,
  CALLER   VARCHAR2(8),
  PEER     VARCHAR2(25),
  CALLTIME DATE,
  DURATION NUMBER(8)
)
tablespace CITY_TMP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  )
;
alter table CB.CALL_TPLAK
  add constraint CALL_TPLAK_FK foreign key (FILE_ID)
  references CB.FILES (ID);

create table CB.FILES
(
  ID        NUMBER(6) not null,
  NAME      VARCHAR2(50) not null,
  FILETIME  DATE not null,
  FILESIZE  NUMBER(9) not null,
  TIME      DATE not null,
  ATS       VARCHAR2(8),
  ATSMODULE NUMBER(2),
  MD5       VARCHAR2(32) not null,
  STATUS    NUMBER(1),
  RECORDS   NUMBER(10),
  BLOCKS    NUMBER(10),
  FTIME     DATE
)
tablespace CITYFILES
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
alter table CB.FILES
  add primary key (ID)
  using index 
  tablespace CITYFILES
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
alter table CB.FILES
  add constraint FILES_FK foreign key (ATS)
  references CB.STATIONS (STATION);

create table CB.CITYUSERS
(
  LOGIN   VARCHAR2(100) not null,
  ATSLIST VARCHAR2(100),
  ACC     NUMBER(1) not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
comment on column CB.CITYUSERS.ACC
  is '0 - тока файло, 1 - файло и запросы, 9 - мегакулхацкер';

insert into cb.cityusers(login,acc) values('&adminlogin','&adminaccess');

create table CB.STATIONS
(
  station       varchar2(8) not null,
  get_protocol  varchar2(8),
  get_hostname  varchar2(30),
  get_username  varchar2(15),
	get_password  varchar2(15),
  get_pattern   varchar2(100),
  get_remotedir varchar2(100),
  get_subdir    varchar2(100),
  homedir       varchar2(100),
  rus_station   varchar2(100)
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
alter table CB.STATIONS
  add primary key (station);  

create table CB.QUERY
(
  ID           NUMBER(11) not null,
  QUERY_DATE   DATE not null,
  PHONE_NUMBER VARCHAR2(25) not null,
  FROMDATE     DATE not null,
  TODATE       DATE not null,
  PROCESSED    NUMBER(1) default 0 not null,
  QUERY_USER   VARCHAR2(25) not null,
  DEST         NUMBER(1) default 3 not null,
  NEEDADDRESS  NUMBER(1),
  ATSLIST      VARCHAR2(100) not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
comment on column CB.QUERY.DEST
  is '1 - входящие, 2 - исходящие, 3 - туда-сюда';

create table CB.QUERY_RESULT
(
  QUERY_ID  NUMBER(11) not null,
  FILE_ID   NUMBER(11) not null,
  CALLER    VARCHAR2(18),
  PEER      VARCHAR2(25),
  CALLTIME  DATE,
  DURATION  NUMBER(6),
  TRUNK_IN  VARCHAR2(16),
  TRUNK_OUT VARCHAR2(16)
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

-- Sequences
create sequence CB.FILES_SQ
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;

create sequence CB.QUERY_ID
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;

-- Triggers
Create Or Replace Trigger CB.files_trg_insert Before Insert On cb.files
Referencing Old As Old New As New For Each Row
Begin
  If Nvl(:New.Id, 0) = 0 Then
    Select files_sq.Nextval Into :New.Id From Dual;
  End If;
End;

Create Or Replace Trigger CB.query_trg_insert Before Insert On cb.query
Referencing Old As Old New As New For Each Row
Begin
  If Nvl(:New.Id, 0) = 0 Then
    Select query_id.Nextval Into :New.Id From Dual;
  End If;
  Select SYSDATE Into :New.query_date From Dual;
End;

-- main procedure
CREATE OR REPLACE PROCEDURE CB.execute_queries IS
CURSOR q IS SELECT * FROM cb.query WHERE processed = 0 ORDER BY query_date ASC;

BEGIN
  FOR rec IN q LOOP
    IF rec.dest in(1,3) THEN
      INSERT INTO cb.query_result SELECT DISTINCT rec.id, c.file_id,c.caller,c.peer,c.calltime,c.duration,c.trunk_in,c.trunk_out FROM cb.call c,cb.files f 
       WHERE f.id = c.file_id and
             c.peer = rec.phone_number and
             (calltime between rec.fromdate and rec.todate+1) and
             rec.atslist like '%'||f.ats||'%';
    END IF;
    IF rec.dest in (2,3) THEN
      INSERT INTO cb.query_result SELECT DISTINCT rec.id, c.file_id,c.caller,c.peer,c.calltime,c.duration,c.trunk_in,c.trunk_out FROM cb.call c,cb.files f 
       WHERE f.id = c.file_id and
             c.caller = rec.phone_number and
             (calltime between rec.fromdate and rec.todate+1) and
             rec.atslist like '%'||f.ats||'%';
    END IF;
    UPDATE cb.query SET processed = 1 WHERE processed = 0 AND id = rec.id;
    COMMIT;
  END LOOP;
  update cb.query_result set peer='363XXXX' where peer like '363____';
  update cb.query_result set peer='364XXXX' where peer like '364____';
--  update cb.query_result set peer=('365XXXX' || substr(peer,8)) where peer like '365______%';
  update cb.query_result set peer=('4154XXXX' || substr(peer,-1)) where peer like '4154_____';
  update cb.query_result set peer=('151154XXXX' || substr(peer,-1)) where peer like '151154_____';
  update cb.query_result set peer='1434XXXX2' where peer like '1434____2';
  update cb.query_result set peer='1534XXXX' where peer like '1534____';
  DELETE FROM cb.query_result
     WHERE query_id IN
          (SELECT id FROM query WHERE processed=1 AND query_date < (SYSDATE - 31));
  UPDATE cb.query SET processed=2 WHERE processed=1 AND query_date < (SYSDATE - 31);
  COMMIT;
END;


-- Users for work
create user DATAFILLER
  identified by "lfnfabkkth"
  default tablespace USERS
  temporary tablespace TEMP
  profile DEFAULT;
grant connect to DATAFILLER;
grant unlimited tablespace to DATAFILLER;
grant insert on cb.call_dama to DATAFILLER;
grant insert on cb.call_oversea to DATAFILLER;
grant insert on cb.call_s12v5 to DATAFILLER;
grant insert on cb.call_s12v7 to DATAFILLER;
grant insert on cb.call_s12wr1a to DATAFILLER;
grant insert on cb.call_tplak to DATAFILLER;
grant insert,update,select on cb.files to DATAFILLER;
grant select,insert on cb.query to DATAFILLER;
grant select on cb.query_result to DATAFILLER;
grant select on cb.files_sq to DATAFILLER;
grant select on cb.cityusers to DATAFILLER;
grant select on cb.stations to DATAFILLER;
grant execute on cb.execute_queries to DATAFILLER;

-- Main view
create or replace view cb.call as
select caller,peer,calltime,duration,file_id,null trunk_in,null trunk_out
 from cb.call_dama
union all
select caller,peer,calltime,duration,file_id,trunk_in,trunk_out
 from cb.call_oversea
union all
select caller,peer,calltime,duration,file_id,null trunk_in,null trunk_out
 from cb.call_s12v5
union all
select caller,peer,calltime,duration,file_id,trunk_in,trunk_out
 from cb.call_s12v7
union all
select caller,peer,calltime,duration,file_id,trunk_in,trunk_out
 from cb.call_s12wr1a
union all
select caller,peer,calltime,duration,file_id,null trunk_in,null trunk_out
 from cb.call_tplak
;

create user REPORTER
  identified by "ciuyrhvv"
  default tablespace USERS
  temporary tablespace TEMP
  profile DEFAULT;
grant connect to REPORTER;
grant select on cb.call to reporter;
