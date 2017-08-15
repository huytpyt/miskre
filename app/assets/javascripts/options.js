Vue.http.interceptors.push(function(request, next) {
  // modify headers
  request.headers.set('X-CSRF-TOKEN', $('meta[name="csrf-token"]').attr('content'));
  
  // continue to next interceptor
  next();
});

var optionResource = Vue.resource( $('#productId').val() + '{/id}.json')

var options = new Vue({
  el: '#options',
  data: {
    options: [],
    editMode: false,
    newOption: {
      name: '',
      values: ''
    },
    errors: {}
  },
  methods: {
    createOption: function () {
      var that = this;
      optionResource.save({option: this.newOption}).then(
        function(response) {
          that.errors = {};
          that.newOption = {
            name: '',
            values: ''
          };
          that.options.push(response.data);
        },
        function(response) {
          that.errors = response.data.errors
        }
      )
    },
    updateOption: function (option) {
      var that = this;
      optionResource.update({id: option.id}, {option: option}).then(
        function (response) {
          that.option = response.data;
          that.editMode = false;
        }
        /*
        function(response) {
          that.errors = {}
          that.option = response.data
          that.editMode = false
        },
        function(response) {
          that.errors = response.data.errors
        }
        */
      )
    },
    removeOption: function(option) {
      // var that = this; 
      // .options.splice(option.id, 1);
      this.options.splice(this.options.indexOf(option), 1)
      optionResource.delete({id: option.id}).then(
        function (response) {
          // that.options.splice(option.id, 1);
          // this.option.splice(this.option.indexOf(todo), 1)
        }
      )
    },
  },
  mounted: function() {
    var that;
    that = this;
    optionResource.get().then(
      function (response) {
        that.options = response.data
      }
    )
  },
});

/*
Vue.component('option-row', {
  template: '#option-row',
  props: {
    option: Object
  },
  data: function () {
    return {
      editMode: false,
      errors: {}
    }
  },
  methods: {
    updateOption: function () {
      var that = this;
      optionResource.update({id: that.option.id}, {option: that.option}).then(
        function(response) {
          that.errors = {}
          that.option = response.data
          that.editMode = false
        },
        function(response) {
          that.errors = response.data.errors
        }
      )
    },
    removeOption: function () {
      var that = this;
      optionResource.delete({id: that.option.id}).then(
        function (response) {
          // this.options.splice(that.option.id, 1);
          this.$remove()
        }
      )
    }
  }
})

var options = new Vue({
  el: '#options',
  data: {
    options: [],
    option: {
      name: '',
      values: ''
    },
    errors: {}
  },
  mounted: function() {
    var that;
    that = this;
    optionResource.get().then(
      function (response) {
        that.options = response.data
      }
    )
  },
  methods: {
    createOption: function () {
      var that = this;
      optionResource.save({option: this.option}).then(
        function(response) {
          that.errors = {};
          that.option = {};
          that.options.push(response.data);
        },
        function(response) {
          that.errors = response.data.errors
        }
      )
    }
  }
});
*/
