
-- version 0.0.0.0 => 0.0.1.1

-- c_version
drop table if exists c_version cascade;

create table c_version (
  version text default 1 not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , constraint c_version_PKC primary key (version)
) ;

comment on table c_version is 'c_version';
comment on column c_version.version is 'version';
comment on column c_version.created is 'created';
comment on column c_version.created_by is 'created_by';
comment on column c_version.updated is 'updated';
comment on column c_version.updated_by is 'updated_by';

INSERT INTO c_version (version) VALUES ('0.0.1.0');

-- Change column description data-type to text.
ALTER TABLE public.t_task
   ALTER COLUMN description TYPE text;

update c_version set version = '0.0.1.1';

