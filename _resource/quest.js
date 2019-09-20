var get_quests = function(){
    $.getJSON("/dangeon", append_quests);
}

var append_quests = function(data){
    $.each(data, function(index, val){
        var content = "<tr>";
        content += "<td align='center'>" + val + "</td>";

        content += "<td id='quest_id' class='nondisplayFrame'>" + index + "</td>";

        content += "</tr>";

        $("#quest_list").append(content);
    });
    
    $(".nondisplayFrame").css('display', 'none');

    set_colorfunc("quest_list");

    $("#quest_list tr").click(function() {
        var value = $(this)[0].cells[1].innerText //タグのidをキーにしてうまいこと引っ張りたい
        $("#candidate_quest_id").empty();
        $("#candidate_quest_id").append("<input type='hidden' id='quest_id' value='" + value + "'>");
    });
}





var situation_correspondence = {
    0: "walking",
    1: "item",
    2: "step",
    3: "goal",
    4: "pot",
    5: "battle",
    6: "finished",
    7: "canceled"
}

var quest_kind_correspondence = {

}

var quest_value_correspondence = {

}


var start_quest = function(){
    $("#log").append("クエスト開始！<br>");

    var partner_id = 5; //あとでちゃんと一覧から取得する様にする
    var quest_id = Number($("input#quest_id")[0].value);
    var party_id = Number($("input#party_id")[0].value);
    var array = [partner_id, party_id, quest_id];

    var json = JSON.stringify(array);

    $.ajax({
		url: "/quest",
		type:'POST',
		dataType: 'json',
		data : json
    }).done(handle_quest_action_result).fail(function(data){
        $("#msg").empty();

        var res = $.parseJSON(data.responseText);

        $("#msg").append(res.ErrorMessage);
    });

}


var do_quest_action = function(kind, value){
    var array = [kind, value];

    var json = JSON.stringify(array);

    $.ajax({
		url: "/quest",
		type:'PUT',
		dataType: 'json',
		data : json
    }).done(handle_quest_action_result).fail(function(data){
        $("#msg").empty();

        var res = $.parseJSON(data.responseText);

        $("#msg").append(res.ErrorMessage);
    });

}


var handle_quest_action_result = function(data){
    $("#msg").empty();
    $("#situation").empty();
    $("#coordinate").empty();
    $("#object").empty();


    $("#coordinate").append("x:" + data.x + "<br/>");
    $("#coordinate").append("y:" + data.y + "<br/>");
    $("#coordinate").append("z:" + data.z + "<br/>");

    $("#situation").append("状況:" + situation_correspondence[data.situation] + "<br/>");

    $("#object").append("部屋にあるもの:" + data.object.name + "<br/>");
}



var do_battle_action = function(kind, value){
    var array = [kind, value];

    var json = JSON.stringify(array);

    $.ajax({
		url: "/battle",
		type:'PUT',
		dataType: 'json',
		data : json
    }).done(handle_battle_action_result).fail(function(data){
        $("#msg").empty();

        var res = $.parseJSON(data.responseText);

        $("#msg").append(res.ErrorMessage);
    });
}

var handle_battle_action_result = function(data){
    $("#msg").empty();
    $("#situation").empty();
    $("#coordinate").empty();
    $("#object").empty();

    if (data.finish_flg == true){
        if (data.enemy.hp == 0){
            $("#log").append("バトルに勝った！<br>");
        }else{
            $("#log").append("バトルに負けた！<br>");
        };
    };
}


var go_up = function(){
    do_quest_action(0,1);
}

var go_left = function(){
    do_quest_action(0,2);
}

var go_down = function(){
    do_quest_action(0,4);
}

var go_right = function(){
    do_quest_action(0,8);
}



var get_item = function(){
    do_quest_action(1,0);
    $("#log").append("アイテムGET<br>");
}

var discard_item = function(){
    do_quest_action(1,1);
    $("#log").append("アイテム捨てた<br>");
}


var attack = function(){
    do_battle_action(0,0);
}


var goal = function(){
    do_quest_action(3,0);
    $("#log").append("クエスト完了<br>");
}


var cancel = function(){
    $.ajax({
		url: "/quest",
		type:'DELETE',
		dataType: 'json',
		data : ""
    }).done(handle_quest_action_result).fail(function(data){
        $("#msg").empty();

        var res = $.parseJSON(data.responseText);

        $("#msg").append(res.ErrorMessage);
    });

    $("#log").append("クエストキャンセルした<br>")
}