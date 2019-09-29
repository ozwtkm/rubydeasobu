
function create_map(num){
	var map = document.getElementById('map');
	var mapn = 0;
	var walln = 0;

	for(var y=0; y<num; y++) {
		for(var x=0; x<num; x++){
			map.innerHTML += '<input type="checkbox" class="map" id="map['+String(mapn)+']" value="1" checked="checked">';
			mapn++;
			
			if (x!=num-1){
				map.innerHTML += '<input type="checkbox" class="wall" id="wall['+String(walln)+']" value="1">';
				walln++;
			}
		}
		map.innerHTML += '<br/>'

		if (y!=num-1){
			for(var x=0; x<num; x++){
				map.innerHTML += '<input type="checkbox" class="wall" id="wall['+String(walln)+']" value="1">&nbsp;&nbsp;&nbsp;';
				walln++;
			}
			map.innerHTML += '<br/>'
		}
	}
}


function submit_mapdata(){
	//var num = document.getElementById('mapnum').value;
	//var mapinfo = create_mapinfo();
	var wallinfo = create_wallinfo();
	
	var dangeon = document.getElementById("dangeon").value
	var floor = document.getElementById("floor").value

	var json = JSON.stringify(wallinfo);
	
	$.ajax({
		url: "/admin_map/" + dangeon + "/" + floor,
		type:'POST',
		dataType: 'json',
		data : json
	}).done(function(data){
		console.log(data);
		//var res = $.parseJSON(data);
		$("#msg").append(data.Message);
	}).fail(function(data){
		var res = $.parseJSON(data.responseText);
		$("#msg").append(res.ErrorMessage);
	});
}

function create_mapinfo(){
	var mapinfo = [];
	var maps=document.getElementsByClassName('map')
	
	for(var i=0; i<maps.length; i++){
		if (maps[i].checked===false){
			maps[i].value=0;
		}else{
			maps[i].value=1;
		}
		mapinfo.push(maps[i].value);
	}
	
	return mapinfo;
}

function create_wallinfo(){
	var wallinfo = [];
	var walls=document.getElementsByClassName('wall')
	
	for(var i=0; i<walls.length; i++){
		if (walls[i].checked===false){
			walls[i].value=0;
		}else{
			walls[i].value=1;
		}
		
		wallinfo.push(Number(walls[i].value));
	}
	
	return wallinfo;
}
