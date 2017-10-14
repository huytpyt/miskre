var ship = new Vue({
  el: '#shipping_prices',
  data: {
    country: 'US',
    epub: 0,
    dhl: 0,
    errors: {}
  },
  methods: {
    lookup_for_price: function() {
      var vm = this;

      var success = function(res) {
        vm.epub = res.data.epub;
        vm.dhl = res.data.dhl;
      }

      var error = function(res) {
        // error callback
      }

      this.$http.get('/find_ship_cost', {
        params: {
          country: vm.country,
          weight: vm.weight,
          length: vm.length,
          height: vm.height,
          width: vm.width
        }
      }).then(success, error);
    }
  }
});
