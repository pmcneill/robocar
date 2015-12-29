#include "Arduino.h"
#include "WifiSetup.h"

#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>
#include <WiFiClient.h>
#include <WiFiClientSecure.h>
#include <ESP8266mDNS.h>
#include <WiFiServer.h>
#include <WiFiUdp.h>
#include <stdio.h>
#include <FS.h>
#include <malloc.h>

#define SSID_FILE "/wifissid"
#define KEY_FILE "/wifikey"
#define CONFIG_FILE "/wificonfigdata"

WiFiServer ws_server(80);
char *ssid = NULL, *key = NULL;

#define WS_READY 0
#define WS_ASK 1
#define WS_CONNECTING 2

int mode = WS_CONNECTING;

void wsResetConfig() {
  SPIFFS.remove(SSID_FILE);
  SPIFFS.remove(KEY_FILE);
  SPIFFS.remove(CONFIG_FILE);
}

int wsNetworkPresent() {
  String s = String(ssid);

  Serial.print("Scanning networks for: ");
  Serial.println(s);

  int numSsid = WiFi.scanNetworks();

  for ( int i = 0 ; i < numSsid ; i++ ) {
    if ( String(WiFi.SSID(i)) == s ) return 1;
  }

  return 0;
}

int wsReadConfig() {
  String s, k;
  int i;
  File f;

  Serial.println("Reading config");

  if ( ssid ) return 1;
  if ( ! SPIFFS.exists(SSID_FILE) ) return 0;

  Serial.println("Found SSID file");

  f = SPIFFS.open(SSID_FILE, "r");
  s = f.readString();
  f.close();

  f = SPIFFS.open(KEY_FILE, "r");
  k = f.readString();
  f.close();

  i = s.length() + 1;
  ssid = (char *)malloc(i);
  s.toCharArray(ssid, i);

  i = k.length() + 1;
  key = (char *)malloc(i);
  k.toCharArray(key, i);

  return 1;
}

int wsTryConnect() {
  if ( ! wsReadConfig() ) return 0;
  if ( ! wsNetworkPresent() ) return 0;

  mode = WS_CONNECTING;

  Serial.println("Network configuration loaded");
  Serial.println(ssid);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, key);

  return 1;
}

String wsGetConfig() {
  String config_data;
  File f;

  f = SPIFFS.open(CONFIG_FILE, "r");
  config_data = f.readString();
  f.close();

  return config_data;
}

int wsValidIP() {
  IPAddress ip = WiFi.localIP();
  return ! ( ip[0] == 0 && ip[1] == 0 && ip[2] == 0 && ip[3] == 0 );
}

int wsRequestPassword() {
  mode = WS_ASK;

  WiFi.mode(WIFI_AP);
  WiFi.softAP("IoT Device");
  MDNS.begin("device");

  ws_server.begin();
  MDNS.addService("http", "tcp", 80);
}

int wsSaveConfig(String data) {
  File f;
  int i, j, len;
  String s;
  char *tmp;

  data.replace("+", " ");
  data.replace("%3A", ":");
  data.replace("%20", " ");
  data.replace("%2F", "/");

  len = data.length();

  Serial.println(data);

  i = data.indexOf("ssid=");
  j = data.indexOf('&', i);
  if ( j < 0 ) j = len;
  s = data.substring(i + 5, j);

  Serial.print("SSID: ");
  Serial.println(s);

  f = SPIFFS.open(SSID_FILE, "w");
  f.print(s);
  f.close();

  i = data.indexOf("pass=");
  j = data.indexOf('&', i);
  if ( j < 0 ) j = len;
  s = data.substring(i + 5, j);

  Serial.print("Password: ");
  Serial.println(s);

  f = SPIFFS.open(KEY_FILE, "w");
  f.print(s);
  f.close();

  i = data.indexOf("config=");
  j = data.indexOf('&', i);
  if ( j < 0 ) j = len;
  s = data.substring(i + 7, j);

  Serial.print("Config: ");
  Serial.println(s);

  f = SPIFFS.open(CONFIG_FILE, "w");
  f.print(s);
  f.close();

  ESP.restart();
}

int wsHandleWebRequest() {
  WiFiClient client = ws_server.available();
      
  if (!client) {
    return 0;
  }

  // Wait for data from client to become available
  while(client.connected() && !client.available()){
    yield();
  }
  
  // Read the first line of HTTP request
  String req = client.readStringUntil('\r');
  
  // First line of HTTP request looks like "GET /path HTTP/1.1"
  // Retrieve the "/path" part by finding the spaces
  int addr_start = req.indexOf(' ');
  int addr_end = req.indexOf(' ', addr_start + 1);
  if (addr_start == -1 || addr_end == -1) {
    Serial.print("Invalid request: ");
    Serial.println(req);
    return 0;
  }
      
  Serial.print("Web request received: ");
  Serial.println(req);

  req = req.substring(addr_start + 1);
  Serial.print("Request: ");
  Serial.println(req);
  client.flush();
  
  String s;
  if ( (addr_start = req.indexOf('?')) >= 0 ) {
    s = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<!DOCTYPE HTML>\r\n<html><body>Thanks</body></html>\r\n\r\n";
    wsSaveConfig(req.substring(addr_start + 1, req.indexOf(' ', addr_start + 2)));
  } else {
    s = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<!DOCTYPE HTML>\r\n<html><body><form method=\"get\">SSID: <input name=\"ssid\"><br/>Pass: <input name=\"pass\"><br/>Extra config data: <input name=\"config\"><br/><input type=\"submit\"></form></body></html>\r\n\r\n";
  }
  client.print(s);

  delay(5);

  return 1;
}

unsigned long connect_at = 0;

// Returns 0 if not connected, 1 if it is
int wsConnected() {
  if ( mode == WS_READY ) return 1;

  if ( mode == WS_ASK ) {
    wsHandleWebRequest();
    return 0;
  }

  if ( wsValidIP() ) {
    mode = WS_READY;
    return 1;
  }

  unsigned long now = millis();

  if ( ! connect_at ) {
    connect_at = now;

    Serial.println("Connecting...");

    // only fails when there's no config or no matching network
    if ( ! wsTryConnect() ) {
      Serial.println("Try connect failed");
      wsRequestPassword();
      mode = WS_ASK;
    }

    return 0;
  }

  // Ask for password after a minute of trying to connect
  if ( now - connect_at > 60000 ) {
    wsRequestPassword();
    mode = WS_ASK;
  }

  return 0;
}
