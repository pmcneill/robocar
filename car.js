
function boot_car(ip) {
  var send_car = function(cmd, params) {
    params = params || {};

    console.log("Telling car: " + cmd);
    console.log(params);

    $.ajax({
      url: "http://" + ip + "/" + cmd,
      data: params
    });
  }

  console.log("Car found at " + ip);
  $("#connecting").addClass("hidden");
  $("#controls").removeClass("hidden");

  $("#controls div.control").click(function() {
    if ( this.id == "mode" ) {
      var $ml = $("#mode_label"), data = { mode: 'wander' };

      if ( $ml.text() != "Manual" ) {
        data.mode = 'manual';
      }

      $ml.text(data.mode.replace(/^[a-z]/, function(c) { return c.toUpperCase(); }));

      send_car("mode", data);
    } else {
      send_car(this.id);
    }
    return false;
  });

  $("#lights").change(function() {
    var patterns = [], pattern, i, j;
    var rainbow = ['f00', 'f80', 'ff0', '0f0', '00f', '408', '80f'];

    if ( this.value[0] == "_" ) {
      for ( i = 0 ; i < 4 ; i++ ) {
        patterns += this.value.substr(1);
      }
    } else {
      switch ( this.value ) {
        case "red_blue":
          patterns = ["f00f0000f00f:250", "00f00ff00f00:250"];
          break;
        case "red_moving":
          for ( i = 0 ; i < 8; i++ ) {
            pattern = "";

            for ( j = 0 ; j < 4 ; j++ ) {
              if ( j == i || ( 7 - i ) == j ) {
                pattern += "f00";
              } else {
                pattern += "000";
              }
            }

            pattern += ":200";

            patterns.push(pattern);
          }
          break;
        case "cycle_rainbow":
          for ( i = 0 ; i < rainbow.length ; i++ ) {
            pattern = "";

            for ( j = 0 ; j < 4 ; j++ ) {
              pattern += rainbow[(i + j) % rainbow.length];
            }

            pattern += ":200";

            patterns.push(pattern);
          }
          break;
        default:
        case "all_rainbow":
          for ( i = 0 ; i < rainbow.length ; i++ ) {
            pattern = "";

            for ( j = 0 ; j < 4 ; j++ ) {
              pattern += rainbow[i];
            }

            pattern += ":200";

            patterns.push(pattern);
          }
      }

      patterns = patterns.join(",");
    }

    send_car("lights", { patterns: patterns });
  });
}

$(function() {
  $.ajax({
    url: "http://patrickmcneill.com/car/ip/",
    cache: false,
    dataType: "json",
    success: function(ips) {
      var tested = 0, num = ips.length;

      ips.forEach(function(ip) {
        console.log(ip);

        $.ajax({
          url: "http://" + ip + "/stop",
          cache: false,
          timeout: 1000,
          success: function(retval) {
            boot_car(ip);
          },
          error: function() {
            tested++;

            if ( tested == num ) {
              $("#connecting").addClass("hidden");
              $("#failed").removeClass("hidden");
            }
          }
        });
      });
    }
  });
});
