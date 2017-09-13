(function() {
    var e, n;
    e = $("#container").get(0), (n = new DAT.Globe(e, {
        imgDir: "/assets/"
    })).createPoints(), n.animate(), $(document).ready(function(e) {
        return function() {
            return $(".hidden-scripts").remove();
        };
    }());
}).call(this);