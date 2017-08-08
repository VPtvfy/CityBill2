create table CQUERY
(
  ID           NUMBER(11) not null,
  QUERY_DATE   DATE not null,
  PHONE_NUMBER VARCHAR2(25) not null,
  FROMDATE     DATE not null,
  TODATE       DATE not null,
  PROCESSED    NUMBER(1) default 0 not null,
  QUERY_USER   VARCHAR2(25) not null,
  DEST         VARCHAR2(4) not null,
  TABNAMES     VARCHAR2(255)
)
tablespace CITYADD
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

create table CQUERY_RESULT
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
tablespace CITYADD
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

create sequence CQUERY_ID
minvalue 1
maxvalue 999999999999999999999999999
start with 847
increment by 1
cache 20;

Create Or Replace Trigger cquery_trg_insert Before Insert On cb.cquery
Referencing Old As Old New As New For Each Row
Begin
  If Nvl(:New.Id, 0) = 0 Then
    Select cquery_id.Nextval Into :New.Id From Dual;
  End If;
  Select SYSDATE Into :New.query_date From Dual;
End;

CREATE OR REPLACE PROCEDURE execute_queries IS
CURSOR q IS SELECT * FROM query WHERE processed = 0 ORDER BY query_date ASC;
BEGIN
  FOR rec IN q LOOP
    INSERT INTO query_result 
      SELECT rec.id AS query_id, c.* FROM call c
           WHERE ((rec.phone_number = c.caller AND (rec.dest = 'out' OR rec.dest = 'both'))
           OR (rec.phone_number = c.peer AND (rec.dest = 'in' OR rec.dest = 'both')))
           AND ((c.file_id not in (select id from files where ats='AMTS')))-- and rec.amts = 0))
--           OR (c.file_id in (select id from files where ats='AMTS') and rec.amts >0))
--           AND (c.file_id in (select id from files where ats='AMTS' and rec.amts = 2))
           AND (c.calltime BETWEEN rec.fromdate AND (rec.todate + 1)) ORDER BY c.calltime;
    UPDATE query SET processed = 1 WHERE processed = 0 AND id = rec.id;
    COMMIT;
  END LOOP;
  update query_result set peer='363XXXX' where peer like '363____';
  update query_result set peer='364XXXX' where peer like '364____';
--  update query_result set peer=('365XXXX' || substr(peer,8)) where peer like '365______%';
  update query_result set peer=('4154XXXX' || substr(peer,-1)) where peer like '4154_____';
  update query_result set peer=('151154XXXX' || substr(peer,-1)) where peer like '151154_____';
  update query_result set peer='1434XXXX2' where peer like '1434____2';
  update query_result set peer='1534XXXX' where peer like '1534____';
  DELETE FROM query_result 
     WHERE query_id IN 
          (SELECT id FROM query WHERE processed=1 AND query_date < (SYSDATE - 31));
  UPDATE query SET processed=2 WHERE processed=1 AND query_date < (SYSDATE - 31);
  COMMIT;
END;
