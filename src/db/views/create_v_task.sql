DROP VIEW IF EXISTS v_task;

CREATE VIEW v_task AS 
SELECT 
  solution.name AS solution,
  typ_task.name AS type,
  task.task_cd AS code,
  task.name AS name,
  typ_status.name AS status,
  creator.name AS created_by,
  modifier.name AS updated_by 
FROM t_task task 
LEFT JOIN t_solution solution 
ON 
  task.solution_cd = solution.solution_cd
LEFT JOIN c_type typ_task 
ON 
  task.task_type = typ_task.type_cd
  AND typ_task.type_category = 'TT'
LEFT JOIN c_type typ_status 
ON 
  task.status_type = typ_status.type_cd
  AND typ_status.type_category = 'TS' 
LEFT JOIN m_user creator 
ON 
  task.created_by = creator.user_cd
LEFT JOIN m_user modifier 
ON 
  task.updated_by = modifier.user_cd

