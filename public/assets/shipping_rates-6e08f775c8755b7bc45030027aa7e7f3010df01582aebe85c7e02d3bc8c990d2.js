var ship = new Vue({
  el: '#shipping_prices',
  data: {
    country: 'US',
    weight: 50,
    epub: 0,
    dhl: 0,
    errors: {}
  },
  methods: {
    lookup_for_price() {
      var vm = this;

      this.$http.get('/find_ship_cost', {
        params: {
          country: vm.country,
          weight: vm.weight
        }
      }).then(response => {
        vm.epub = response.data.epub
        vm.dhl = response.data.dhl
      }, response => {
        // error callback
      });
    }
  }
});