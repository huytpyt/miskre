Vue.http.interceptors.push(function(request, next) {
  // modify headers
  request.headers.set('X-CSRF-TOKEN', $('meta[name="csrf-token"]').attr('content'));
  
  // continue to next interceptor
  next();
});

var variantResource = Vue.resource( $('#variantsResource').val() + '{/id}.json')

var variants = new Vue({
  el: '#variants',
  data: {
    variants: [],
    editMode: false,
    errors: {}
  },
  methods: {
    reloadVariants() {
      var vm = this;
      axios.get($('#variantsReload').val()).then(function (response) {
        vm.variants = response.data;
      }).catch(function (error) {
        vm.errors = response.data.errors;
      });

    },
    updateVariant(variant) {
      var vm = this;
      variantResource.update({id: variant.id}, {variant: variant}).then(
        function (response) {
          vm.variant = response.data;
          vm.editMode = false;
        }
      )
    },
    removeVariant(variant) {
      var vm = this;
      this.variants.splice(this.variants.indexOf(variant), 1)
      variantResource.delete({id: variant.id}).then(
        function (response) {
          // that.options.splice(option.id, 1);
          // this.option.splice(this.option.indexOf(todo), 1)
        }
      )
    },
  },
  mounted: function() {
    var vm = this;
    variantResource.get().then(
      function (response) {
        vm.variants = response.data
      }
    )
  }
});
