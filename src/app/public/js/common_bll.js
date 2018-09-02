
// function ajax(type, url, data, success, error, opts) {
//   return $.ajax(
//     $.extend(true, 
//       {
//         type : type,
//         url : url,
//         dataType : 'json',
//         success : success,
//         error : error,
//         data : (data !== undefined)? JSON.stringify(data) : undefined
//       }, 
//       (opts !== undefined && opts !== null)? opts : {}
//   ));
// }

function messageUpdateSuccess(message) {
  $.messager.show({
      title:'Info',
      msg:'Update success.<br>'+message,
      timeout:3000,
      showType:'fade'
  });
}

function messageUpdateError(message) {
  $.messager.show({
      title:'Error',
      msg:'Error occured!<br>'+message,
      timeout:3000,
      showType:'fade'
  });
}

function defaultUpdtSuccessCallback(data, dataType) {
  if(data.success) {
    console.log("success");
    console.log(data);
    messageUpdateSuccess(data.message);
  } else {
    messageUpdateError(data.message);
  }
}

function defaultUpdtErrorCallback(XMLHttpRequest, textStatus, errorThrown) {
  console.log("error");
  console.log(errorThrown);
  messageUpdateError(errorThrown.message);
}

function singleInsUpd(vue, propNameSelectedRow, treegrid, fnNewRecord, partUrl, after) {
  $.ajax({
    type: "POST",
    url: "/"+partUrl,
    data: JSON.stringify(vue[propNameSelectedRow]),
    success: function(data, dataType) { 
      defaultUpdtSuccessCallback(data, dataType);
      if(data.success) {
        vue[propNameSelectedRow] = fnNewRecord();
        if(after) {
          after(data);
        } else {
          treegrid.treegrid("reload");
        }
      }
    },
    error: defaultUpdtErrorCallback,
    dataType: "json"
  });
}

function singleDel(vue, partUrl, propNameSelected, propNameCd, treegrid, fnNewRecord) {
  $.ajax({
    type: "DELETE",
    url: "/"+partUrl+"/" + vue[propNameSelected][propNameCd],
    data: JSON.stringify(vue[propNameSelected]),
    success: function(data, dataType) { 
      defaultUpdtSuccessCallback(data, dataType);

      treegrid.treegrid("reload");
      vue[propNameSelected] = fnNewRecord();
    },
    error: defaultUpdtErrorCallback,
    dataType: "json"
  });
}

function batchUpd(vue, propNameDiff, propNameSelections, treegrid, fnNewRecord, partUrl) {
  $.ajax({
    type: "POST",
    url: "/batch/" + partUrl,
    data: JSON.stringify({rows : vue[propNameSelections], diff : vue[propNameDiff]}),
    success: function(data, dataType) { 
      defaultUpdtSuccessCallback(data, dataType);

      treegrid.treegrid("reload");
      vue[propNameDiff] = fnNewRecord();
    },
    error: defaultUpdtErrorCallback,
    dataType: "json"
  });
}

function batchDel(vue, propNameSelected, propNameSelections, treegrid, fnNewRecord, partUrl) {
  $.ajax({
    type: "DELETE",
    url: "/batch/" + partUrl,
    data: JSON.stringify({rows : vue[propNameSelections]}),
    success: function(data, dataType) { 
      defaultUpdtSuccessCallback(data, dataType);

      treegrid.treegrid("reload");
      vue[propNameDiff] = fnNewRecord();
    },
    error: defaultUpdtErrorCallback,
    dataType: "json"
  });
}

function batchManualUpd(partUrl, treegrid, rows, diff) {
  $.ajax({
    type: "POST",
    url: "/batch/" + partUrl,
    data: JSON.stringify({rows : rows, diff : diff}),
    success: function(data, dataType) { 
      defaultUpdtSuccessCallback(data, dataType);
      treegrid.treegrid("reload");
    },
    error: defaultUpdtErrorCallback,
    dataType: "json"
  });
}

function singleNew(vue, propNameSelected, treegrid, fnNewRecord, propNameMultiRowSelected) {
  vue[propNameSelected] = fnNewRecord();
  treegrid.treegrid("clearSelections");
  if(propNameMultiRowSelected) {
    vue[propNameMultiRowSelected] = false;
  }
}

function singleCopy(vue, propNameSelected, treegrid, fnCopyRecord, propNameMultiRowSelected) {
  vue[propNameSelected] = fnCopyRecord();
  treegrid.treegrid("clearSelections");
  if(propNameMultiRowSelected) {
    vue[propNameMultiRowSelected] = false;
  }
}

