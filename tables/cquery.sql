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
  atslist      varchar2(50) not null
);

create sequence CQUERY_ID
minvalue 1
maxvalue 999999999999999999999999999
start with 867
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
