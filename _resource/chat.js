function init() {

	function debug(string) {
		var element = document.getElementById("debug");
		var p = document.createElement("p");
		p.appendChild(document.createTextNode(string));
		element.appendChild(p);
	}
	
	var Socket = WebSocket;
	var ws = new Socket("ws://192.168.119.128:81/unko/");
	
	ws.onclose = function(event) {	
		debug("Closed - code: " + event.code + ", reason: " + event.reason + ", wasClean: " + event.wasClean);
	};
	
	ws.onopen = function() {
		debug("connected...");
	};

	ws.onmessage = function(event){
		var message_li = $('<li>').text(event.data);
		$("#msg-area").append(message_li);
	};
		
	$("#send").on('click', function(){
		ws.send($('#message').val());
	});
	
	$("#logout").on('click', function(){
		ws.close();
	});
	
};

$(document).ready(function(){
	init();
});
