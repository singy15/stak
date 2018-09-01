
$.fn.datetimebox.defaults.formatter = function(date){
  return moment(date).format("DD-MM-YYYY HH:mm");
  // var y = date.getFullYear();
  // var m = date.getMonth()+1;
  // var d = date.getDate();
  // var h = date.getHours();
  // var mm = date.getMinutes();
  // return m+'/'+d+'/'+y + " " + h +":"+ mm;
}

$.fn.datetimebox.defaults.parser = function(date){
  var m = moment(date, "DD-MM-YYYY HH:mm");
  if(m.isValid()) {
    return m.toDate();
  } else {
    return moment().startOf('day').toDate();
  }

  // var y = date.getFullYear();
  // var m = date.getMonth()+1;
  // var d = date.getDate();
  // var h = date.getHours();
  // var mm = date.getMinutes();
  // return m+'/'+d+'/'+y + " " + h +":"+ mm;
}
