
function genFormatter(_paths, _fn) {
  var paths = _paths;
  var fn = _fn;
  return function(value,row,index) {
    var obj;
    var curpath;
    var rslts = [];
    for(var j = 0; j<paths.length; j+=1) {
      obj = row;
      curpath = paths[j].split(".");
      for(var i = 0; i<curpath.length; i+=1) {
        if((obj !== "") && (obj[curpath[i]] != null) && (obj[curpath[i]] !== undefined)) {
          obj = obj[curpath[i]];
        } else {
          obj = "";
        }
      }
      rslts.push(obj);
    }
    return rslts.join(".");
  }
}

function createMultiSelectFilter(dg, field, data) {
  return {
    field:field,
    type:'combobox',
    //op : ["in", "equal"],
    options:{
      panelHeight:'auto',
      data : data,
      valueField : "value",
      textField : "text",
      multiple : true,
      editable :false,
      user_opened : false, //whether if panel opened
      icons: [
        {
          iconCls:'icon-checked',
          handler: function(e){
            var selected = $(e.data.target).combobox("getValues");
            var values = $(e.data.target).combobox('getData');
            if((values.length != selected.length)) {
              for(var i = 0; i < values.length; i += 1) {
                $(e.data.target).combobox("select", values[i].value);
              }
            } else {
              $(e.data.target).combobox("clear");
            }

            console.log($(e.data.target).combobox("panel"));

            if($(e.data.target).combobox("options").user_opened == false) {
              dg.datagrid('doFilter');
            }
          },
        }
      ],
      onChange:function(value,oldValue) {
        if (value.length == 0){
          dg.datagrid('removeFilterRule', field);
        } else {
          dg.datagrid('addFilterRule', {
              field: field,
              op: 'in',
              value: value.join(",")
          });
        }

        var data = $(this).combobox("getData");
        if (value.length == 0) {
          $(this).combobox("setText", "");
        }
        else if(value.length > 1) {
          if(value.length == data.length) {
            $(this).combobox("setText", "");
          } else {
            $(this).combobox("setText", "Multiple");
          }
        } else if(value.length == 1) {
          $(this).combobox("setText", _.filter(data, function(e){ return e.value === value[0]; })[0].text);
        }
        // dg.datagrid('doFilter');
      },
      onShowPanel:function() {
        $(this).combobox("options").user_opened = true;
      },
      onHidePanel:function() {
        $(this).combobox("options").user_opened = false;
        dg.datagrid('doFilter');
      }
    }
  }
}

function createSingleSelectFilter(dg, field, data) {
  return {
    field:field,
    type:'combobox',
    editable:false,
    options:{
      panelHeight:'auto',
      valueField : "value",
      textField : "text",
      data : data,
      onChange:function(value){
        if (value == ''){
            dg.datagrid('removeFilterRule', field);
        } else {
            dg.datagrid('addFilterRule', {
                field: field,
                op: 'equal',
                value: value
            });
        }
        dg.datagrid('doFilter');
      }
    }
  }
}

function createLabelFilter(field) {
  return {
    field:field,
    type:'label'
  }
}

