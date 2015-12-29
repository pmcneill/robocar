#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>
#include <ESP8266mDNS.h>
#include "WifiSetup.h"
#include <stdio.h>
#include <malloc.h>
#include <FS.h>
#include <Adafruit_NeoPixel.h>
#include <ESP8266WebServer.h>

ESP8266WebServer server(80);
int greeted = 0;

// ints, instead of #defines, so they can be reconfigured on the fly (later..)
int led_pin = 14;      // NodeMCU 5
int l_bumper_pin = 12; //         6
int r_bumper_pin = 13; //         7

void set_routes() {
  server.on("/forward", []() {
    set_motors(1, 1);
  });
  
  server.on("/reverse", []() {
    set_motors(-1, -1);
  });
  
  server.on("/left", []() {
    set_motors(-1, 1);
  });
  
  server.on("/right", []() {
    set_motors(1, -1);
  });

  server.on("/stop", []() {
    set_motors(0, 0);
  });

  server.on("/lights", handle_lights);
  server.on("/query", handle_query);
  server.on("/mode", handle_mode);

  server.begin();
}

int report_ip() {
  IPAddress ip = WiFi.localIP();
  WiFiClient client;

  if (!client.connect("patrickmcneill.com", 80)) {
    return 0;
  }

  client.print(String("GET /car/ip/register?ip=") + ip[0] + "." + ip[1] + "." + ip[2] + "." + ip[3] + " HTTP/1.0\r\n" +
               "Host: patrickmcneill.com\r\n" + 
               "Connection: close\r\n\r\n");

  delay(10);

  while(client.available()){
    client.readStringUntil('\n');
  }

  return 1;
}

void respond(const char *text) {
//  server.sendHeader("Connection", "close");
//  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "text/json", text);
}

void set_motor(int dir, int pwr_pin, int dir_pin) {
  if ( dir == 0 ) {
    digitalWrite(pwr_pin, 0);
  } else {
    digitalWrite(pwr_pin, 1);
    digitalWrite(dir_pin, dir > 0 ? 1 : 0);
  }
}

void set_motors(int left, int right) {
  set_motor(left, 5, 0);
  set_motor(right, 4, 2);
  respond("1");
}

/*
 * LED handling.  To set up, make a request to /lights with
 * the pattern as the argument.  The pattern is a list of
 * 4 RGB colors, in hexadecimal.  Each color channel is 4 bits, so
 * 0-F.  Animation can done by adding
 * a colon, milliseconds of delay (decimal), a comma, and another
 * color pattern.  A pattern can have up to 100 frames.  For
 * instance, here's a red/blue flasher:
 * 
 * F00F0000F00F:500,00F00FF00F00:500
 * 
 * This will set LEDs 1+2 to red (F00) and 3+4 to blue (00F).  After
 * 500ms, 1+2 will go blue and 3+4 red, also for 500ms.  It'll
 * then go back to the beginning of the pattern.
 */

#define LEDS 4

Adafruit_NeoPixel leds = Adafruit_NeoPixel(LEDS, led_pin);

#define MAX_PATTERNS 100

typedef struct {
  short r[LEDS];
  short g[LEDS];
  short b[LEDS];
  unsigned int ms;
} pattern;

pattern patterns[MAX_PATTERNS];

int num_patterns = 0;
int cur_pattern = -1;
unsigned long cur_pattern_start = 0;

void handle_lights() {
  int i;
  
  cur_pattern = -1;
  num_patterns = 0;

  if ( ! server.hasArg("patterns") ) return;

  String data = server.arg("patterns");
  data.toUpperCase();
  data.replace("%3A", ":");
  data.replace("%2C", ",");

  Serial.println("Reading lights");
  Serial.println(data);

  const char *nums = "0123456789ABCDEF";
  int accum = 0, j = 0;
  char in_num_p = 0;

  for ( i = 0 ; i < data.length() ; i++ ) {
    if ( data[i] == ',' ) {
      if ( in_num_p ) {
        patterns[num_patterns].ms = accum;
      }
      
      num_patterns++;
      in_num_p = 0;
      j = 0;
    } else if ( data[i] == ':' ) {
      in_num_p = 1;
      accum = 0;
    } else if ( in_num_p ) {
      accum = accum * 10 + (strchr(nums, data[i]) - nums);
    } else {
      // should be the start of an RGB triad
      patterns[num_patterns].r[j] = strchr(nums, data[i++]) - nums;
      patterns[num_patterns].g[j] = strchr(nums, data[i++]) - nums;
      patterns[num_patterns].b[j] = strchr(nums, data[i]) - nums;
      j++;
    }
  }

  patterns[num_patterns].ms = accum;
  num_patterns++;

/*
  for ( i = 0 ; i < num_patterns ; i++ ) {
    Serial.println(String("Pattern ") + i + ": " + patterns[i].r[0] + ", " + patterns[i].g[0] + ", " + patterns[i].b[0] + " for " + patterns[i].ms);
  }
*/

  respond("1");
}

void refresh_lights(unsigned long now) {
  // Rolls over every 50 days, so unlikely to hit, but let's be good coders.
  if ( now < cur_pattern_start ) cur_pattern_start = 0;

  // If "now" is not "ms" past when we started displaying the 
  // current pattern, there's nothing to do here.
  if ( cur_pattern >= 0 &&
       (num_patterns <= 1 || patterns[cur_pattern].ms > (now - cur_pattern_start) ) ) {
    return;
  }

  cur_pattern_start = now;

  int i;

  if ( num_patterns == 0 ) {
    for ( i = 0 ; i < LEDS; i++ ) {
      leds.setPixelColor(i, 0, 0, 0);
    }

    return;
  }

  cur_pattern = (cur_pattern + 1) % num_patterns;

  leds.begin();

  for ( i = 0 ; i < LEDS; i++ ) {
    // Input colors are 0-15.  Multiply by 17 to scale it to 0-255.
    leds.setPixelColor(i, (int)patterns[cur_pattern].r[i] * 17, (int)patterns[cur_pattern].g[i] * 17, (int)patterns[cur_pattern].b[i] * 17);
  }

  leds.show();
}

/*
 * Mode handling.  Right now, this is "manual" or "wander".
 * Manual is just remote controlled.  Wander will move forward
 * until one of the bumpers is pressed.  When that happens, it'll
 * back up for one second and then turn away from the pressed
 * bumper for a random portion of one second.
 */

#define MANUAL 0
#define WANDER 1
short wander_mode = MANUAL;

void handle_mode() {
  wander_mode = MANUAL;
  
  if ( server.hasArg("mode") && server.arg("mode") == String("wander") ) {
    Serial.println("Wandering!");
    wander_mode = WANDER;
  }

  respond("1");
}

short avoiding_p = 0; // -1 for left, +1 for right
unsigned long do_started = 0;
unsigned long do_for = 0;

void refresh_wander(unsigned long now) {
  if ( wander_mode == MANUAL ) return;

  int l, r;
  
  if ( do_started && (now - do_started) < do_for ) return;

  // If we get here, it's because it's completed the backup portion.  Rotate now.
  if ( avoiding_p ) {
    do_started = now;
    do_for = random(250, 1001);
    set_motors(avoiding_p, -avoiding_p);
    avoiding_p = 0;
    return;
  }

  l = digitalRead(l_bumper_pin);
  r = digitalRead(r_bumper_pin);

  if ( l == 0 || r == 0 ) {
    do_started = now;
    do_for = 1000;
    avoiding_p = (l == 0) ? 1 : -1;
    set_motors(-1, -1);
    return;
  }

  do_started = 0;
  do_for = 0;

  set_motors(1, 1);
}

void handle_query() {
  respond("Query results");
}

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);

  if ( ! SPIFFS.begin() ) {
    SPIFFS.format();
    SPIFFS.begin();
  }

  // motors
  pinMode(0, OUTPUT);
  pinMode(2, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);

  // sensors / effectors
  pinMode(led_pin, OUTPUT);
  pinMode(l_bumper_pin, INPUT_PULLUP);
  pinMode(r_bumper_pin, INPUT_PULLUP);
}

void loop() {
  if ( ! wsConnected() ) {
    delay(50);
    return;
  }

  if ( ! greeted ) {
    if ( report_ip() ) {
      Serial.println("Reported IP address");
      set_routes();
      greeted = 1;
    } else {
      delay(500);
      return;
    }
  }

  int now = millis();

  server.handleClient();

  refresh_lights(now);
  refresh_wander(now);
}
