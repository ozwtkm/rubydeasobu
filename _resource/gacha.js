
var get_monsters = function(offset,number){
	$.getJSON("/monsters/offset/" + offset + "/number/" + number, append_monsters_list);
	
	var next = String(Number(offset) + Number(number));
	var back = String(Number(offset) - Number(number));
	
	document.getElementById('next_offset').value = next;
	document.getElementById('back_offset').value = back;
	
	document.getElementById('range').innerText = String(Number(offset)+1) + "～" + next + "を表示中";
}


var get_wallet = function(){
	$.getJSON("/wallet", append_wallet);
}


function append_monsters_list(data){
	$('#monsters_list').empty();

	$.each(data, function(index, val){
		$("#monsters_list").append("<tr>");
		$.each(val, function(index, val){
			switch(index){
				case "name":
					$("#monsters_list").append("<td align='left'>" + val + "</td>");	
					break;
				case "rarity":
					$("#monsters_list").append("<td align='center'>" + val + "</td>");
					break;
			}
		});
		$("#monsters_list").append("</tr>");
	});
}


function append_wallet(data){
	$.each(data, function(index, val){
		switch(index){
			case "gem":
				$("#gem").append(val);
				break;
			case "money":
				$("#money").append(val);
				break;
		}
	});
}
