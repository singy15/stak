
function WorkplanDomain() {
  BaseDomain.call(this);
}

inherits(WorkplanDomain, BaseDomain);

WorkplanDomain.prototype.copyRecord = function(source) {
  var record = this.getNewRecord();
  record.task_cd = null;
  record.task_cd2 = source.task_cd2;
  record.parent_cd = source.parent_cd;
  record.start_date = source.start_date;
  record.end_date = source.end_date;
  record.progress = source.progress;
  record.user_cd = source.user_cd;
  record.name = source.name;
  record.parent_cd = source.parent_cd;
  record.sort_order = 0;
  record.work_type = source.work_type;
  record.solution_cd = source.solution_cd;
  record.task_type = source.task_type;
  record.description = source.description;
  record.priority_type = source.priority_type;
  record.status_type = source.status_type;
  return record;
};

WorkplanDomain.prototype.getNewRecord = function() {
  return { 
    task_cd : null,
    task_cd2 : "",
    parent_cd : "",
    start_date : moment().format("DD-MM-YYYY HH:mm"),
    end_date : moment().add(7,"days").format("DD-MM-YYYY HH:mm"),
    progress : 0.0,
    user_cd : Constants.DEFAULTS.DEFAULT_USER_CD,
    name : "",
    parent_cd : "",
    sort_order : 0,
    work_type : Constants.WORKPLAN_TYPE.PLAN,
    solution_cd : Constants.DEFAULTS.DEFAULT_SOLUTION_CD,
    task_type : Constants.TASK_TYPE.TASK,
    description : "",
    priority_type : Constants.TASK_PRIORITY.MEDIUM,
    status_type : Constants.TASK_STATUS.NEW
  };
};

