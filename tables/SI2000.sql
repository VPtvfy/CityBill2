-- Create table
create table CALL_SI2000
(
  FILE_ID     NUMBER(11) not null,
  CALLER      VARCHAR2(20),
  PEER        VARCHAR2(25),
  CALLTIME    DATE,
  DURATION    NUMBER(6),
  csn         varchar2(8),
  recseq      number(3),
  charge      number(3),
  connected   VARCHAR2(25),
  dialed      VARCHAR2(25),
  end_time    date,
  pulse       number(8),
  suppservice number(3),
	callerdn    number(3),
  calleddn    number(3),
	trunk_in    varchar2(4),
  trunk_out   varchar2(4)
) compress
partition by range (CALLTIME)
SUBPARTITION BY HASH(peer)
SUBPARTITION TEMPLATE(
SUBPARTITION SP0,
SUBPARTITION SP1,
SUBPARTITION SP2,
SUBPARTITION SP3,
SUBPARTITION SP4,
SUBPARTITION SP5,
SUBPARTITION SP6,
SUBPARTITION SP7,
SUBPARTITION SP8,
SUBPARTITION SP9)
(
  partition P200901 values less than (TO_DATE('2009-02-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2009,
  partition P200902 values less than (TO_DATE('2009-03-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2009,
  partition P200903 values less than (TO_DATE('2009-04-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2009,
  partition P200904 values less than (TO_DATE('2009-05-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2009,
  partition P200905 values less than (TO_DATE('2009-06-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2009,
  partition P200906 values less than (TO_DATE('2009-07-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2009,
  partition P200907 values less than (TO_DATE('2009-08-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2009,
  partition P200908 values less than (TO_DATE('2009-09-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2009,
  partition P200909 values less than (TO_DATE('2009-10-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2009,
  partition P200910 values less than (TO_DATE('2009-11-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2009,
  partition P200911 values less than (TO_DATE('2009-12-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2009,
  partition P200912 values less than (TO_DATE('2010-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2009,

  partition P201001 values less than (TO_DATE('2010-02-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2010,
  partition P201002 values less than (TO_DATE('2010-03-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2010,
  partition P201003 values less than (TO_DATE('2010-04-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2010,
  partition P201004 values less than (TO_DATE('2010-05-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2010,
  partition P201005 values less than (TO_DATE('2010-06-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2010,
  partition P201006 values less than (TO_DATE('2010-07-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2010,
  partition P201007 values less than (TO_DATE('2010-08-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2010,
  partition P201008 values less than (TO_DATE('2010-09-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2010,
  partition P201009 values less than (TO_DATE('2010-10-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2010,
  partition P201010 values less than (TO_DATE('2010-11-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2010,
  partition P201011 values less than (TO_DATE('2010-12-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2010,
  partition P201012 values less than (TO_DATE('2011-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) tablespace CITY2010
)
;
