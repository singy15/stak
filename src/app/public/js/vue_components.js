
// icon-button
Vue.component('icon-button', {
  data: function () {
    return {}
  },
  methods: {
    getCss : function() {
      return ["icon", this.icon];
    },
    onClick : function() {
      this.$emit('on-click');
    }
  },
  props : {
    icon : String,
    text : String
  },
  template: 
  // `
  // <span 
  //   v-bind:class="getCss()" 
  //   v-on:click="onClick" 
  //   style="cursor: pointer">
  //   {{ text }}
  // </span>
  // `
  ''
  + '<span '
    + 'v-bind:class="getCss()" '
    + 'v-on:click="onClick" '
    + 'style="cursor: pointer">'
    + '{{ text }}'
  + '</span>'
// '\
// <span \
//   v-bind:class="getCss()"\
//   v-on:click="onClick"\
//   style="cursor: pointer">\
//   {{ text }}\
// </span>\
// '
});

// toggle-checkbox
Vue.component('toggle-checkbox', {
  data: function () {
    return {
      toggleState : true
    }
  },
  methods: {
    onChangeToggle : function() {
      this.$emit('on-click', this.toggleState);
    }
  },
  props : {
    textOn : String,
    textOff : String
  },
  watch : {
    toggleState : 'onChangeToggle'
  },
  template: 
  // `
  //   <label style="font-size:0.5em; vertical-align:middle;" >
  //     <input 
  //       type="checkbox" 
  //       v-bind:checked="toggleState" 
  //       style="width:12px;height:12px" 
  //       v-model="toggleState"/>
  //     {{ (toggleState)? textOn : textOff }}
  //   </label>
  // `
  ''
  + '<label style="font-size:0.5em; vertical-align:middle;" >'
    + '<input '
      + 'type="checkbox" '
      + 'v-bind:checked="toggleState" '
      + 'style="width:12px;height:12px" '
      + 'v-model="toggleState"/>'
      + '{{ (toggleState)? textOn : textOff }}'
  + ' </label>'
  
});

// footer-button
Vue.component('footer-button', {
  data: function () { 
    return {
    };
  },
  props : {
    text : String,
    id : String
  },
  template: 
  // `
  //   <div v-bind:id="id" class="w3-button">{{ text }}</div>
  // `
  '<div v-bind:id="id" class="w3-button">{{ text }}</div>'
});

// input-cd
Vue.component('input-cd', {
  props : { 
    value : String,
    size : Number
  },
  methods : {
    onClick : function(ev) {
      this.$emit('input', ev.target.value);
    }
  },
  computed : {
    disp : function() {
      return ((this.value == null) || (this.value === undefined) || (this.value === ""))? "NEW" : this.value;
    },
    style : function() {
      return {
        width : (10 * this.size).toString() + "px"
      };
    }
  },
  template: 
  // `
  //   <input v-bind:style="style" readonly v-bind:value="disp" v-on:input="$emit('input', $event.target.value)" >
  // `
  '<input v-bind:style="style" readonly v-bind:value="disp" v-on:input="onClick" >'
});

// field-value
Vue.component('field-value', {
  template: 
  // `
  //   <div class="field_value"><slot></slot></div>
  // `
  '<div class="field_value"><slot></slot></div>'
});

// field-header
Vue.component('field-header', {
  template: 
  // `
  //   <div class="field_header"><slot></slot></div>
  // `
  '<div class="field_header"><slot></slot></div>'
});

