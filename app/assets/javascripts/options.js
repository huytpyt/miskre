Vue.http.interceptors.push(function(request, next) {
  // modify headers
  request.headers.set('X-CSRF-TOKEN', $('meta[name="csrf-token"]').attr('content'));
  // continue to next interceptor
  next();
});

var optionResource = Vue.resource( $('#optionsResource').val() + '{/id}.json')

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
    createOption: function() {
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
    updateOption: function(option) {
      var that = this;
      optionResource.update({id: option.id}, {option: option}).then(
        function (response) {
          that.editMode = false;
        }
      )
    },
    removeOption: function(option) {
      this.options.splice(this.options.indexOf(option), 1)
      optionResource.delete({id: option.id}).then(
        function (response) {
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
