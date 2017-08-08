-- Create table
create table CFILES
(
  ID       NUMBER(6) not null,
  NAME     VARCHAR2(50) not null,
  FILETIME DATE not null,
  FILESIZE NUMBER(9) not null,
  TIME     DATE not null,
  ATS      VARCHAR2(6),
  MD5      VARCHAR2(32),
  MD5DUP   VARCHAR2(32),
  STATUS   NUMBER(1)
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
-- Create/Recreate primary, unique and foreign key constraints 
alter table CFILES
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
alter table CFILES
  add unique (FILESIZE, MD5)
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
