
-- version 0 => 1

-- c_version
drop table if exists c_version cascade;

create table c_version (
  version integer default 1 not null
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

INSERT INTO c_version (version) VALUES ('0');

alter table t_task alter start_dt type varchar(16);
alter table t_task alter end_dt type varchar(16);

alter table t_task add user_cd varchar(3);
update t_task set user_cd = '';
alter table t_task alter user_cd set default '';
alter table t_task alter user_cd set not null;

alter table t_task add sort_order bigint;
update t_task set sort_order = to_number(to_char(now(), 'YYMMDDHH24MISSMSUS'),'9999999999999999999');
alter table t_task alter sort_order set default to_number(to_char(now(), 'YYMMDDHH24MISSMSUS'),'9999999999999999999');
alter table t_task alter sort_order set not null;

alter table t_task add progress numeric;
update t_task set progress = 0.0;
alter table t_task alter progress set default 0.0;
alter table t_task alter progress set not null;

alter table t_task add sort_order_dbl numeric;
update t_task set sort_order_dbl = sort_order;
alter table t_task alter sort_order_dbl set default to_number(to_char(now(), 'YYMMDDHH24MISSMSUS'),'9999999999999999999');
alter table t_task alter sort_order_dbl set not null;

alter table t_task alter sort_order type numeric;


update c_version set version = '1';

