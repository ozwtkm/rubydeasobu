var get_userinfo = function(){
    $.getJSON("/user", append_user_info);
}

function append_user_info(data){
    $('#userinfo').empty();
    $('#userinfo').append(data.username + "でログイン中");
 }

var get_parties = function(){
    $.getJSON("/party", append_parties_list);
}

function append_parties_list(data){
    $('#parties_list_body').empty();

    $.each(data, function(index,val){
        index
        var content = "<tr>";

        content += "<td align='center'>" + index + "</td>";

        $.each(val, function(index, val){
            switch(index){
                case "name":
                    content += "<td align='left'>" + val + "</td>";
                    break;
                case "rarity":
                    content += "<td align='center'>" + val + "</td>";
                    break;
                case "hp":
                    content += "<td align='center'>" + val + "</td>";
                    break;
                case "mp":
                    content += "<td align='center'>" + val + "</td>";
                    break;
                case "speed":
                    content += "<td align='center'>" + val + "</td>";
                    break;
                case "atk":
                    content += "<td align='center'>" + val + "</td>";
                    break;
                case "def":
                    content += "<td align='center'>" + val + "</td>";
                    break;
            }
        });

        content += "<td id='party_id' class='nondisplayFrame'>" + index + "</td>";
        content += "</tr>";
        $("#parties_list_body").append(content);
    });

    $(".nondisplayFrame").css('display', 'none');
    set_colorfunc("parties_list_body");
    $("#parties_list_body tr").click(function() {
        var value = $(this)[0].cells[8].innerText //タグのidをキーにしてうまいこと引っ張りたい
        $("#candidate_party_id").empty();
        $("#candidate_party_id").append("<input type='hidden' id='party_id' value='" + value + "'>");
    });
}


var set_colorfunc = function(id){
    $("#" + id + " tr").click(function() {
        $("#" + id + " tr").css("background-color", ""); 
        $(this).css("background-color", "red"); 
    });
}


var get_monsters = function(offset){
	$.getJSON("/monsters/" + offset, append_monsters_list);
	
	var next = String(Number(offset) + 10);
	var back = String(Number(offset) - 10);
	
	document.getElementById('next_offset').value = next;
	document.getElementById('back_offset').value = back;
	
	document.getElementById('range').innerText = String(Number(offset)+1) + "～" + next + "を表示中";
}


var get_items = function(offset){
	$.getJSON("/item/" + offset, append_items_list);
	
	var next = String(Number(offset) + 10);
	var back = String(Number(offset) - 10);
	
	document.getElementById('item_next_offset').value = next;
	document.getElementById('item_back_offset').value = back;
	
	document.getElementById('item_range').innerText = String(Number(offset)+1) + "～" + next + "を表示中";
}




function append_items_list(data){
    $('#item_list').empty();

	$.each(data, function(index, val){
        var content = "<tr>";

		$.each(val, function(index, val){
			switch(index){
				case "name":
                    content += "<td align='left'>" + val + "</td>";	
					break;
				case "kind":
                    content += "<td align='center'>" + convert_item_kind(val) + "</td>";
                    break;
                case "value":
                    content +="<td align='center'>" + val + "</td>";
                    break;
                case "quantity":
                    content +="<td align='center'>" + val + "</td>";
                    break;                
                case "possession_id":
                    content += "<td id='possession_item_id' class='nondisplayFrame'>" + val + "</td>";
                    break;
			}
		});

        content += "</tr>";
        $("#item_list").append(content);
	});
}


var do_update_party = function(){
    var possession_monster_id = Number($("input#possession_monster_id")[0].value);
    var party_id = Number($("input#party_id")[0].value);
    var array = [party_id, possession_monster_id];

    var json = JSON.stringify(array);

    $.ajax({
		url: "/party",
		type:'PUT',
		dataType: 'json',
		data : json
	}).done(function(data){
        append_parties_list(data);
        $("#msg").empty();
        $("#msg").append("updateしたよ");
	}).fail(function(data){
        var res = $.parseJSON(data.responseText);
        $("#msg").empty();
		$("#msg").append(res.ErrorMessage);
	});
}




var get_wallet = function(){
	$.getJSON("/wallet", append_wallet);
}


function append_monsters_list(data){
    $('#monsters_list').empty();

	$.each(data, function(index, val){
        var content = "<tr>";

		//$("#monsters_list").append("<tr>");
		$.each(val, function(index, val){
			switch(index){
				case "name":
                    content += "<td align='left'>" + val + "</td>";	
					break;
				case "rarity":
                    content += "<td align='center'>" + convert_rarity(val) + "</td>";
                    break;
                case "hp":
                    content +="<td align='center'>" + val + "</td>";
                    break;
                case "mp":
                    content +="<td align='center'>" + val + "</td>";
                    break;
                case "speed":
                    content +="<td align='center'>" + val + "</td>";
                    break;
                case "atk":
                    content +="<td align='center'>" + val + "</td>";
                    break;
                case "def":
                    content +="<td align='center'>" + val + "</td>";
                    break;
                case "possession_id":
                    content += "<td id='possession_monster_id' class='nondisplayFrame'>" + val + "</td>";
                    break;
			}
		});

        //content += "<td id='possession_monster_id' class='nondisplayFrame'>" + val["possession_monster_id"] + "</td>";
        content += "</tr>";
        $("#monsters_list").append(content);

        $(".nondisplayFrame").css('display', 'none');
        set_colorfunc("monsters_list");
       // set_candidatefunc("parties_list_body","candidate_party_id","possession_monster_id");
        $("#monsters_list tr").click(function() {
            var value = $(this)[0].cells[0].innerText //タグのidをキーにしてうまいこと引っ張りたい
            $("#candidate_possession_monster_id").empty();
            $("#candidate_possession_monster_id").append("<input type='hidden' id='possession_monster_id' value='" + value + "'>");
        });
	});
}

function convert_rarity(rarity){
    var correspondence={
        "0": "normal",
        "1": "rare",
        "2": "Srare",
        "3": "SSrare"
    }

    return correspondence[rarity]
}


function convert_item_kind(kind){
    var item_correspondence={
        "2": "HP回復",
        "1": "バフ"
    }

    return item_correspondence[kind]
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

