/**
 * mi.js
 * 
 * These functions are only meant for calling back to the ios/android app.
 * In no way are they meant to inhibit the performance of the jailbreak
 * as the calls will be asynchronous. AKA Helper functions to let the android
 * app know what is going on.
 */

 function sendPrq(path, data) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', path, true);
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    var data = JSON.stringify(data);
    xhr.send(data);
}

function sendHrq(path) {
    var xhr = new XMLHttpRequest();
    xhr.open('HEAD', path, true);
    xhr.send('');
}

function sendGrq(path) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', path, true);
    xhr.send('');
}

function response(message, data) {
   return {"response": message, "data": data }
}


function predone() {
   scanPayload()
}

function olddone()
{
   if(main_ret == 0 || main_ret == 179)
   {
       alert("You're all set!");
       setTimeout(function() { read_ptr_at(0); }, 1);
   }
   else
       alert("Jailbreak failed! Reboot your PS4 and try again.");
}


function done()
{
   if(main_ret == 0 || main_ret == 179)
   {
       sendMiSuccess()
       setTimeout(function() { read_ptr_at(0); }, 1);
   }
   else sendMiFailed()
}

function sendCommand(message, cmd){
   var path = "/jb/cmd"
   sendPrq(path, response(message, {"cmd": cmd}))
}

function scanPayload() {
    var message = "mi.js requesting payload to send to port 9020"
    var cmd = "send.payload"
    sendCommand(message, cmd)
}

function sendStart(){
    var message = "Starting jailbreak process... please wait"
    var cmd = "jb.started"
    sendCommand(message, cmd)
}

function sendInitiated() {
    var message = "Loaded home page"
    var cmd = "jb.initiated"
    sendCommand(message, cmd)
}

function sendMiSuccess(){
    var message = "You're all set! Special thanks to the special players in the JB Community!"
    var cmd = "jb.success"
    sendCommand(message, cmd)
    alert(message)
}

function sendPayload(){
    var message = "mi.js is fetching payload to send to port 9020"
    var cmd = "send.pending"
    sendCommand(message, cmd)
}


function sendPayloadRequest(){
    var message = "mi.js is fetching the payload"
    var cmd = "send.payload.request"
    sendCommand(message, cmd)
}


function sendPressX(message){
    var cmd = "jb.continue"
    sendCommand(message, cmd)
}



function sendMiFailed(){
   var message = "Jailbreak failed. Please reboot your PS4 and try again"
   var cmd = "jb.failed"
   sendCommand(message, cmd)
   alert(message)
}