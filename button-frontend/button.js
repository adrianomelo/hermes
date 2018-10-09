"use strict";
var connection = null;
var clientID = 0;

var WebSocket = WebSocket || MozWebSocket;

//function connect() {
  var serverUrl = "ws://localhost:8888/websocket";

  connection = new WebSocket(serverUrl);

  connection.onclose = function(e) {
    console.log('onclose', e)
    connection = new WebSocket(serverUrl);
  }

  connection.onopen = function(evt) {
    const id = Math.abs(Math.random() * 1000);
    const date = Date.now();
    const agent = {
      date,
      id
    }
    send('REGISTER', agent);
  };

  connection.onmessage = function(evt) {
    console.log('onmessage', evt)
    var msg = JSON.parse(evt.data);
    var time = new Date(msg.date);
    var timeStr = time.toLocaleTimeString();

    switch(msg.type) {
      case "id":
        break;
      default:
    }
  };
//}

function send(type, payload) {
  var msg = {
    type,
    payload: payload || {}
  };
  connection.send(JSON.stringify(msg));
}

function handleKey(evt) {
  if (evt.keyCode === 13 || evt.keyCode === 14) {
    send('BTN_DOWN');
  }
}

window.addEventListener("keyup", handleKey);

