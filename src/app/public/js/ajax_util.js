
function ajax(type, url, data, success, error, opts) {
  return $.ajax(
    $.extend(true, 
      {
        type : type,
        url : url,
        dataType : 'json',
        success : success,
        error : error,
        data : (data !== undefined)? JSON.stringify(data) : undefined
      }, 
      (opts !== undefined && opts !== null)? opts : {}
  ));
}

