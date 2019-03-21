
var get_monsters = function(){

	$.getJSON("/monsters", append_monsters_list);

}


var get_wallet = function(){

	$.getJSON("/wallet", append_wallet);

}


function append_monsters_list(data){

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
	
		$.each(val, function(index, val){

			switch(index){
				case "gem":
					$("#gem").append(val);
					break;
				case "money":
					$("#money").append(val);
					break;
			}

		});

	});

}
