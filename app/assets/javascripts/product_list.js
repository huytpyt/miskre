Vue.http.interceptors.push(function(request, next) {
  // modify headers
  request.headers.set('X-CSRF-TOKEN', $('meta[name="csrf-token"]').attr('content'));
  // continue to next interceptor
  next();
});

var productsResource = Vue.resource( $('#productsResource').val() + '{/id}.json')

var products = new Vue({
  el: '#products',
  data: {
    products: [],
    editMode: false,
    errors: {}
  },
  methods: {
    edit_link: function(product_id) {
      return "/products/" + product_id + "/edit";
    }
  },
  mounted: function() {
    var vm = this;
    productsResource.get().then(
      function (response) {
        vm.products = response.data
      }
    )
  }
});
