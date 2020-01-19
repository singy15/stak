-- Project Name : taskmng
-- Date/Time    : 2020/01/18 8:38:06
-- Author       : admin
-- RDBMS Type   : PostgreSQL
-- Application  : A5:SQL Mk-2

-- t_whiteboard
drop table if exists t_whiteboard cascade;

create table t_whiteboard (
  whiteboard_cd varchar(7) not null
  , task_cd varchar(7) not null
  , content text default '<mxGraphModel><root><mxCell id="0"/><mxCell id="1" parent="0"/></root></mxGraphModel>' not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint t_whiteboard_PKC primary key (whiteboard_cd)
) ;

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

-- t_workplan
drop table if exists t_workplan cascade;

create table t_workplan (
  work_plan_cd varchar(11) not null
  , task_cd varchar(7) not null
  , name varchar(500) default '' not null
  , start_date varchar(10) default '' not null
  , end_date varchar(10) default '' not null
  , progress numeric default 0.0 not null
  , parent_cd varchar(11) default '' not null
  , user_cd varchar(3) default '' not null
  , sort_order bigint default to_number(to_char(now(), 'YYMMDDHH24MISSMSUS'),'9999999999999999999') not null
  , work_type varchar(6) default 'WT01TS' not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint t_workplan_PKC primary key (work_plan_cd)
) ;

-- c_code_def
drop table if exists c_code_def cascade;

create table c_code_def (
  code_type varchar(6) not null
  , cd_len bigint not null
  , max_seq bigint not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint c_code_def_PKC primary key (code_type)
) ;

-- t_blob
drop table if exists t_blob cascade;

create table t_blob (
  solution_cd varchar(2) not null
  , task_cd varchar(7) not null
  , comment_cd varchar(10) not null
  , blob_cd varchar(13) not null
  , caption varchar(500) default '' not null
  , data bytea not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint t_blob_PKC primary key (blob_cd)
) ;

-- t_user_solution_rel
drop table if exists t_user_solution_rel cascade;

create table t_user_solution_rel (
  solution_cd varchar(2) not null
  , user_cd varchar(3) not null
  , rel_type varchar(6) not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint t_user_solution_rel_PKC primary key (solution_cd,user_cd,rel_type)
) ;

-- t_work_actual
drop table if exists t_work_actual cascade;

create table t_work_actual (
  solution_cd varchar(2) not null
  , task_cd varchar(7) not null
  , work_plan_cd varchar(11) default '' not null
  , work_actual_cd varchar(11) not null
  , user_cd varchar(3) not null
  , workload int not null
  , begindttm timestamp not null
  , enddttm timestamp not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint t_work_actual_PKC primary key (work_actual_cd)
) ;

-- c_type
drop table if exists c_type cascade;

create table c_type (
  type_cd varchar(6) not null
  , type_category varchar(2) not null
  , type_part varchar(2) not null
  , name varchar(100) not null
  , sort_order int default 0 not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint c_type_PKC primary key (type_cd)
) ;

-- c_numbering
drop table if exists c_numbering cascade;

create table c_numbering (
  numbering_type varchar(2) not null
  , parent_cd varchar(20) default '' not null
  , seq bigint default 0 not null
  , max_seq bigint not null
  , cd_len int not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint c_numbering_PKC primary key (numbering_type,parent_cd)
) ;

-- t_work_plan
drop table if exists t_work_plan cascade;

create table t_work_plan (
  solution_cd varchar(2) not null
  , task_cd varchar(7) default '' not null
  , work_plan_cd varchar(11) not null
  , user_cd varchar(3) default '' not null
  , workload int default 0 not null
  , begindttm timestamp
  , enddttm timestamp
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint t_work_plan_PKC primary key (work_plan_cd)
) ;

-- t_user_task_rel
drop table if exists t_user_task_rel cascade;

create table t_user_task_rel (
  task_cd varchar(7) not null
  , user_cd varchar(3) not null
  , rel_type varchar(6) not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint t_user_task_rel_PKC primary key (task_cd,user_cd,rel_type)
) ;

-- m_user
drop table if exists m_user cascade;

create table m_user (
  user_cd varchar(3) not null
  , name varchar(100) not null
  , login_id varchar(100) not null
  , password text not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint m_user_PKC primary key (user_cd)
) ;

-- m_tag
drop table if exists m_tag cascade;

create table m_tag (
  tag_cd varchar(3) not null
  , name varchar(100) not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint m_tag_PKC primary key (tag_cd)
) ;

-- t_tag_task_rel
drop table if exists t_tag_task_rel cascade;

create table t_tag_task_rel (
  task_cd varchar(7) not null
  , tag_cd varchar(3) not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint t_tag_task_rel_PKC primary key (task_cd,tag_cd)
) ;

-- t_comment
drop table if exists t_comment cascade;

create table t_comment (
  solution_cd varchar(2) not null
  , task_cd varchar(7) not null
  , comment_cd varchar(10) not null
  , content varchar(500) default '' not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint t_comment_PKC primary key (comment_cd)
) ;

create unique index t_comment_IX1
  on t_comment(task_cd,comment_cd);

-- t_task_task_rel
drop table if exists t_task_task_rel cascade;

create table t_task_task_rel (
  task_cd_a varchar(7) not null
  , task_cd_b varchar(7) not null
  , rel_type varchar(6) not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint t_task_task_rel_PKC primary key (task_cd_a,task_cd_b,rel_type)
) ;

-- t_task
drop table if exists t_task cascade;

create table t_task (
  solution_cd varchar(2) not null
  , task_cd varchar(7) not null
  , task_type varchar(6) not null
  , name varchar(100) not null
  , status_type varchar(6) default 'TS-NW' not null
  , description text default '' not null
  , start_dt varchar(25) default '' not null
  , end_dt varchar(25) default '' not null
  , priority_type varchar(6) default 'TP-NM' not null
  , parent_cd varchar(7) default '' not null
  , root_parent_cd varchar(7) default '' not null
  , path varchar(500) default '' not null
  , start_date varchar(25) default '' not null
  , duration integer default 1 not null
  , progress numeric default 0.0 not null
  , user_cd varchar(3) default '' not null
  , sort_order bigint default to_number(to_char(now(), 'YYMMDDHH24MISSMSUS'),'9999999999999999999') not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint t_task_PKC primary key (task_cd)
) ;

create unique index t_task_IX1
  on t_task(solution_cd,task_cd);

-- t_solution
drop table if exists t_solution cascade;

create table t_solution (
  solution_cd varchar(2) not null
  , name varchar(100) not null
  , status_type varchar(6) default 'SS-NW' not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint t_solution_PKC primary key (solution_cd)
) ;

-- v_type_task_priority
drop view if exists v_type_task_priority;

create view v_type_task_priority as 
select type_cd, name, sort_order from c_type where type_category = 'TP'
;

-- v_type_solution_status
drop view if exists v_type_solution_status;

create view v_type_solution_status as 
select type_cd, name, sort_order from c_type where type_category = 'SS'
;

-- v_type_task_type
drop view if exists v_type_task_type;

create view v_type_task_type as 
select type_cd, name, sort_order from c_type where type_category = 'TT'
;

-- v_type_task_status
drop view if exists v_type_task_status;

create view v_type_task_status as 
select type_cd, name, sort_order from c_type where type_category = 'TS'
;

comment on table t_whiteboard is 't_whiteboard';
comment on column t_whiteboard.whiteboard_cd is 'whiteboard_cd';
comment on column t_whiteboard.task_cd is 'task_cd';
comment on column t_whiteboard.content is 'content';
comment on column t_whiteboard.created is 'created';
comment on column t_whiteboard.created_by is 'created_by';
comment on column t_whiteboard.updated is 'updated';
comment on column t_whiteboard.updated_by is 'updated_by';
comment on column t_whiteboard.version is 'version';

comment on table c_version is 'c_version';
comment on column c_version.version is 'version';
comment on column c_version.created is 'created';
comment on column c_version.created_by is 'created_by';
comment on column c_version.updated is 'updated';
comment on column c_version.updated_by is 'updated_by';

comment on table t_workplan is 't_workplan';
comment on column t_workplan.work_plan_cd is 'work_plan_cd';
comment on column t_workplan.task_cd is 'task_cd';
comment on column t_workplan.name is 'name';
comment on column t_workplan.start_date is 'start_date';
comment on column t_workplan.end_date is 'end_date';
comment on column t_workplan.progress is 'progress';
comment on column t_workplan.parent_cd is 'parent_cd';
comment on column t_workplan.user_cd is 'user_cd';
comment on column t_workplan.sort_order is 'sort_order';
comment on column t_workplan.work_type is 'work_type';
comment on column t_workplan.created is 'created';
comment on column t_workplan.created_by is 'created_by';
comment on column t_workplan.updated is 'updated';
comment on column t_workplan.updated_by is 'updated_by';
comment on column t_workplan.version is 'version';

comment on table c_code_def is 'c_code_def';
comment on column c_code_def.code_type is 'code_type';
comment on column c_code_def.cd_len is 'cd_len';
comment on column c_code_def.max_seq is 'max_seq';
comment on column c_code_def.created is 'created';
comment on column c_code_def.created_by is 'created_by';
comment on column c_code_def.updated is 'updated';
comment on column c_code_def.updated_by is 'updated_by';
comment on column c_code_def.version is 'version';

comment on table t_blob is 't_blob';
comment on column t_blob.solution_cd is 'solution_cd';
comment on column t_blob.task_cd is 'task_cd';
comment on column t_blob.comment_cd is 'comment_cd';
comment on column t_blob.blob_cd is 'blob_cd';
comment on column t_blob.caption is 'caption';
comment on column t_blob.data is 'data';
comment on column t_blob.created is 'created';
comment on column t_blob.created_by is 'created_by';
comment on column t_blob.updated is 'updated';
comment on column t_blob.updated_by is 'updated_by';
comment on column t_blob.version is 'version';

comment on table t_user_solution_rel is 't_user_solution_rel';
comment on column t_user_solution_rel.solution_cd is 'solution_cd';
comment on column t_user_solution_rel.user_cd is 'user_cd';
comment on column t_user_solution_rel.rel_type is 'rel_type';
comment on column t_user_solution_rel.created is 'created';
comment on column t_user_solution_rel.created_by is 'created_by';
comment on column t_user_solution_rel.updated is 'updated';
comment on column t_user_solution_rel.updated_by is 'updated_by';
comment on column t_user_solution_rel.version is 'version';

comment on table t_work_actual is 't_work_actual';
comment on column t_work_actual.solution_cd is 'solution_cd';
comment on column t_work_actual.task_cd is 'task_cd';
comment on column t_work_actual.work_plan_cd is 'work_plan_cd';
comment on column t_work_actual.work_actual_cd is 'work_actual_cd';
comment on column t_work_actual.user_cd is 'user_cd';
comment on column t_work_actual.workload is 'workload';
comment on column t_work_actual.begindttm is 'begindttm';
comment on column t_work_actual.enddttm is 'enddttm';
comment on column t_work_actual.created is 'created';
comment on column t_work_actual.created_by is 'created_by';
comment on column t_work_actual.updated is 'updated';
comment on column t_work_actual.updated_by is 'updated_by';
comment on column t_work_actual.version is 'version';

comment on table c_type is 'c_type';
comment on column c_type.type_cd is 'type_cd';
comment on column c_type.type_category is 'type_category';
comment on column c_type.type_part is 'type_part';
comment on column c_type.name is 'name';
comment on column c_type.sort_order is 'sort_order';
comment on column c_type.created is 'created';
comment on column c_type.created_by is 'created_by';
comment on column c_type.updated is 'updated';
comment on column c_type.updated_by is 'updated_by';
comment on column c_type.version is 'version';

comment on table c_numbering is 'c_numbering';
comment on column c_numbering.numbering_type is 'numbering_type';
comment on column c_numbering.parent_cd is 'parent_cd';
comment on column c_numbering.seq is 'seq';
comment on column c_numbering.max_seq is 'max_seq';
comment on column c_numbering.cd_len is 'cd_len';
comment on column c_numbering.created is 'created';
comment on column c_numbering.created_by is 'created_by';
comment on column c_numbering.updated is 'updated';
comment on column c_numbering.updated_by is 'updated_by';
comment on column c_numbering.version is 'version';

comment on table t_work_plan is 't_work_plan';
comment on column t_work_plan.solution_cd is 'solution_cd';
comment on column t_work_plan.task_cd is 'task_cd';
comment on column t_work_plan.work_plan_cd is 'work_plan_cd';
comment on column t_work_plan.user_cd is 'user_cd';
comment on column t_work_plan.workload is 'workload';
comment on column t_work_plan.begindttm is 'begindttm';
comment on column t_work_plan.enddttm is 'enddttm';
comment on column t_work_plan.created is 'created';
comment on column t_work_plan.created_by is 'created_by';
comment on column t_work_plan.updated is 'updated';
comment on column t_work_plan.updated_by is 'updated_by';
comment on column t_work_plan.version is 'version';

comment on table t_user_task_rel is 't_user_task_rel';
comment on column t_user_task_rel.task_cd is 'task_cd';
comment on column t_user_task_rel.user_cd is 'user_cd';
comment on column t_user_task_rel.rel_type is 'rel_type';
comment on column t_user_task_rel.created is 'created';
comment on column t_user_task_rel.created_by is 'created_by';
comment on column t_user_task_rel.updated is 'updated';
comment on column t_user_task_rel.updated_by is 'updated_by';
comment on column t_user_task_rel.version is 'version';

comment on table m_user is 'm_user';
comment on column m_user.user_cd is 'user_cd';
comment on column m_user.name is 'name';
comment on column m_user.created is 'created';
comment on column m_user.created_by is 'created_by';
comment on column m_user.updated is 'updated';
comment on column m_user.updated_by is 'updated_by';
comment on column m_user.version is 'version';

comment on table m_tag is 'm_tag';
comment on column m_tag.tag_cd is 'tag_cd';
comment on column m_tag.name is 'name';
comment on column m_tag.created is 'created';
comment on column m_tag.created_by is 'created_by';
comment on column m_tag.updated is 'updated';
comment on column m_tag.updated_by is 'updated_by';
comment on column m_tag.version is 'version';

comment on table t_tag_task_rel is 't_tag_task_rel';
comment on column t_tag_task_rel.task_cd is 'task_cd';
comment on column t_tag_task_rel.tag_cd is 'tag_cd';
comment on column t_tag_task_rel.created is 'created';
comment on column t_tag_task_rel.created_by is 'created_by';
comment on column t_tag_task_rel.updated is 'updated';
comment on column t_tag_task_rel.updated_by is 'updated_by';
comment on column t_tag_task_rel.version is 'version';

comment on table t_comment is 't_comment';
comment on column t_comment.solution_cd is 'solution_cd';
comment on column t_comment.task_cd is 'task_cd';
comment on column t_comment.comment_cd is 'comment_cd';
comment on column t_comment.content is 'content';
comment on column t_comment.created is 'created';
comment on column t_comment.created_by is 'created_by';
comment on column t_comment.updated is 'updated';
comment on column t_comment.updated_by is 'updated_by';
comment on column t_comment.version is 'version';

comment on table t_task_task_rel is 't_task_task_rel';
comment on column t_task_task_rel.task_cd_a is 'task_cd_a';
comment on column t_task_task_rel.task_cd_b is 'task_cd_b';
comment on column t_task_task_rel.rel_type is 'rel_type';
comment on column t_task_task_rel.created is 'created';
comment on column t_task_task_rel.created_by is 'created_by';
comment on column t_task_task_rel.updated is 'updated';
comment on column t_task_task_rel.updated_by is 'updated_by';
comment on column t_task_task_rel.version is 'version';

comment on table t_task is 't_task';
comment on column t_task.solution_cd is 'solution_cd';
comment on column t_task.task_cd is 'task_cd';
comment on column t_task.task_type is 'task_type';
comment on column t_task.name is 'name';
comment on column t_task.status_type is 'status_type';
comment on column t_task.description is 'description';
comment on column t_task.start_dt is 'start_dt';
comment on column t_task.end_dt is 'end_dt';
comment on column t_task.priority_type is 'priority_type';
comment on column t_task.parent_cd is 'parent_cd';
comment on column t_task.root_parent_cd is 'root_parent_cd';
comment on column t_task.path is 'path';
comment on column t_task.start_date is 'start_date';
comment on column t_task.duration is 'duration';
comment on column t_task.progress is 'progress';
comment on column t_task.user_cd is 'user_cd';
comment on column t_task.created is 'created';
comment on column t_task.created_by is 'created_by';
comment on column t_task.updated is 'updated';
comment on column t_task.updated_by is 'updated_by';
comment on column t_task.version is 'version';

comment on table t_solution is 't_solution';
comment on column t_solution.solution_cd is 'solution_cd';
comment on column t_solution.name is 'name';
comment on column t_solution.status_type is 'status_type';
comment on column t_solution.created is 'created';
comment on column t_solution.created_by is 'created_by';
comment on column t_solution.updated is 'updated';
comment on column t_solution.updated_by is 'updated_by';
comment on column t_solution.version is 'version';

