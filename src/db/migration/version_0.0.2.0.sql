
-- version 0.0.1.2 => 0.0.2.0

-- t_whiteboard
drop table if exists t_whiteboard cascade;

create table t_whiteboard (
  whiteboard_cd varchar(10) not null
  , task_cd varchar(7) not null
  , content text default '<mxGraphModel><root><mxCell id="0"/><mxCell id="1" parent="0"/></root></mxGraphModel>' not null
  , created timestamp default now() not null
  , created_by varchar(3) default '' not null
  , updated timestamp default now() not null
  , updated_by varchar(3) default '' not null
  , version timestamp default now() not null
  , constraint t_whiteboard_PKC primary key (whiteboard_cd)
) ;

comment on table t_whiteboard is 't_whiteboard';
comment on column t_whiteboard.whiteboard_cd is 'whiteboard_cd';
comment on column t_whiteboard.task_cd is 'task_cd';
comment on column t_whiteboard.content is 'content';
comment on column t_whiteboard.created is 'created';
comment on column t_whiteboard.created_by is 'created_by';
comment on column t_whiteboard.updated is 'updated';
comment on column t_whiteboard.updated_by is 'updated_by';
comment on column t_whiteboard.version is 'version';

INSERT INTO public.t_whiteboard(whiteboard_cd, task_cd, content) VALUES ('00-0000-00', '00-0000', '<mxGraphModel><root><mxCell id="0"/><mxCell id="1" parent="0"/></root></mxGraphModel>');

UPDATE c_version SET version = '0.0.2.0';

