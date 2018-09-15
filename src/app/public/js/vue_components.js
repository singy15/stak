
// icon-button
Vue.component('icon-button', {
  data: function () {
    return {}
  },
  methods: {
    getCss : function() {
      return ["icon", this.icon];
    }
  },
  props : {
    icon : String,
    text : String
  },
  template: 
  `
    <span 
      v-bind:class="getCss()" 
      v-on:click="$emit('on-click')" 
      style="cursor: pointer">
      {{ text }}
    </span>
  `
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
  `
    <label style="font-size:0.5em; vertical-align:middle;" >
      <input 
        type="checkbox" 
        v-bind:checked="toggleState" 
        style="width:12px;height:12px" 
        v-model="toggleState"/>
      {{ (toggleState)? textOn : textOff }}
    </label>
  `
});


