#include <IRremote.h>

IRrecv IrReceiver(15);

#include <WiFi.h>
#include <ESPmDNS.h>
#include <WebSocketsServer.h>

const char *ssid = "warmenhoven";
const char *mdnsid = "kymera";

WebSocketsServer webSocket = WebSocketsServer(80);

struct Conn {
  struct Conn *next;
  uint8_t num;
};
struct Conn *connections = NULL;

void dumpConnections() {
  struct Conn *cur = connections;
  Serial.print("Current WS connections: ");
  while (cur) {
    Serial.printf("%u ", cur->num);
    cur = cur->next;
  }
  Serial.println();
}

void addConnection(uint8_t num) {
  struct Conn *newconn = new Conn;
  newconn->next = NULL;
  newconn->num = num;
  if (!connections) {
    connections = newconn;
  } else {
    struct Conn *tmp = connections;
    while (tmp->next) tmp = tmp->next;
    tmp->next = newconn;
  }
  dumpConnections();
}

void removeConnection(uint8_t num) {
  if (connections->num == num) {
    struct Conn *remconn = connections;
    connections = connections->next;
    delete remconn;
  } else {
    struct Conn *prev = connections;
    struct Conn *cur = connections->next;
    while (cur) {
      if (cur->num == num) {
        prev->next = cur->next;
        delete cur;
        cur = NULL;
      } else {
        prev = cur;
        cur = cur->next;
      }
    }
  }
  dumpConnections();
}

void broadcast(const char *msg) {
  struct Conn *cur = connections;
  while (cur) {
    webSocket.sendTXT(cur->num, msg);
    cur = cur->next;
  }
}

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
  switch(type) {
    case WStype_CONNECTED:
      addConnection(num);
      break;

    case WStype_DISCONNECTED:
    removeConnection(num);
      break;

    default:
      break;
    }
}

void setup() {
  Serial.begin(115200);

  // initialize digital pin LED_BUILTIN as an output.
  pinMode(LED_BUILTIN, OUTPUT);
  IrReceiver.enableIRIn();  // Start the receiver
  IrReceiver.blink13(true); // Enable feedback LED

  // Connect to WiFi network
  WiFi.begin(ssid);

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }
  Serial.print("Connected to " ); Serial.print(ssid); Serial.print(" as "); Serial.println(WiFi.localIP());

  webSocket.begin();
  webSocket.onEvent(webSocketEvent);

  // Set up mDNS responder
  while (!MDNS.begin(mdnsid)) {
    delay(500);
  }
  Serial.print("mDNS responder started as "); Serial.println(mdnsid);

  // Add service to MDNS-SD
  MDNS.addService("kymera", "tcp", 80);
}

void loop() {
  webSocket.loop();

  if (IrReceiver.decode()) {
    decode_type_t type = IrReceiver.results.decode_type;
    bool isRepeat = IrReceiver.results.isRepeat;
    if (type == NEC && !isRepeat) {
      uint8_t command = 0;
      switch (IrReceiver.results.value) {
        case 0x20DF807F:
          command = 1;
          break;
        case 0x20DF28D7:
          command = 2;
          break;
        case 0x20DF40BF:
          command = 3;
          break;
        case 0x20DFC03F:
          command = 4;
          break;
        case 0x20DF00FF:
          command = 5;
          break;
        case 0x20DFA05F:
          command = 6;
          break;
        case 0x20DF609F:
          command = 7;
          break;
        case 0x20DFE01F:
          command = 8;
          break;
        case 0x20DF20Df:
          command = 9;
          break;
        case 0x20DF906F:
          command = 10;
          break;
        case 0x20DF50AF:
          command = 11;
          break;
        case 0x20DFD02F:
          command = 12;
          break;
        case 0x20DF10EF:
          command = 13;
          break;
        default:
          break;
      }
      Serial.printf("Got command %u (0x%x)\n", command, IrReceiver.results.value);
      if (command) {
        char msg[128] = {0};
        snprintf(msg, 128, "%u", command);
        broadcast(msg);
      }
    }
    IrReceiver.resume();
  }
}
