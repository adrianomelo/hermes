"use strict";
var connection = null;
var clientID = 0;

var WebSocket = WebSocket || MozWebSocket;

//function connect() {
  var serverUrl = "ws://localhost:8080/websocket";

  connection = new WebSocket(serverUrl);

  connection.onclose = function(e) {
    console.log('onclose', e)
    connection = new WebSocket(serverUrl);
  }

  connection.onopen = function(evt) {
    console.log('onopen')
    const id = Math.abs(Math.random() * 1000);
    const date = Date.now();
    const agent = {
      date,
      id
    }
    // send({type: 'REGISTER', agent});
  };

  function sendLatency(latencyMsg) {
    const backMsg = {
      ...latencyMsg,
      type: 'LATENCY_RESPONSE',
    }
    send(backMsg)
  }

  connection.onmessage = function(evt) {
    console.log('onmessage', evt)
    var msg = JSON.parse(evt.data);
    //var time = new Date(msg.date);
    //var timeStr = time.toLocaleTimeString();

    switch(msg.type) {
      case "ECHO":
        send({...msg, type: 'ECHO_BACK'})
        break;
      default:
    }
  };
//}

function send(msg) {
  connection.send(JSON.stringify(msg));
}

function handleKey(evt) {
  if (evt.keyCode === 13 || evt.keyCode === 14) {
    send({type: 'BTN_DOWN'});
  }
}

window.addEventListener("keyup", handleKey);

