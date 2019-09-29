

var get_recipes = function(){
    $.getJSON("/gradeup", append_recipe_list);
}



function append_recipe_list(data){
	$('#gache_list').empty();


	$.each(data, function(index, val){
		var content = "<tr>";

		$.each(val, function(index2, val2){
			switch(index2){
				case "name":
					content += "<td align='center'>" + val2 + "</td>";
					break;
				case "id":
					content += "<td id='recipe_id' class='nondisplayFrame'>" + val2 + "</td>";
					break;
			}
		});

		content += "</tr>";

		$("#recipe_list").append(content);
	});

	$(".nondisplayFrame").css('display', 'none');

    set_colorfunc("recipe_list");

    $("#recipe_list tr").click(function() {
        var value = $(this)[0].cells[0].innerText //タグのidをキーにしてうまいこと引っ張りたい
        $("#candidate_recipe_id").empty();
        $("#candidate_recipe_id").append("<input type='hidden' id='recipe_id' value='" + value + "'>");
    });
}


var execute_gradeup = function(){
    var recipe_id = Number($("input#recipe_id")[0].value);

    var array = [recipe_id];

	var json = JSON.stringify(array);

    $.ajax({
		url: "/gradeup",
		type:'POST',
		dataType: 'json',
		data : json
    }).done(handle_gradeup_result).fail(function(data){
        $("#msg").empty();

        var res = $.parseJSON(data.responseText);

        $("#msg").append(res.ErrorMessage);
    });

}


var handle_gradeup_result = function(data){
	$("#msg").empty();
	var rarity = convert_rarity(data.rarity);

	$("#msg").append(data.name + "をゲットした! レア度：　" + rarity);
}