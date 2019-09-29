var admin_login = function(){
    var username = document.getElementById('username').value;
    var password = document.getElementById('password').value;

    var array = [username, password];

    var json = JSON.stringify(array);

    $.ajax({
		url: "/admin_login",
		type:'POST',
		dataType: 'json',
		data : json
    }).done(handle_login_result).fail(function(data){
        $("#msg").empty();

        if ($.isArray(data.responseJSON) === true){
            $.each(data.responseJSON, function(index, val){
                $("#msg").append(val.ErrorMessage);
                $("#msg").append("<br>");
            });
        }else{
            $("#msg").append(data.responseJSON.ErrorMessage);    
        }
    });

}


var handle_login_result = function(data){
    $("#msg").empty();
    $("#msg").append("管理者ログイン成功<br/>");
}