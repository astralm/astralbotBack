module.exports = function(data, callback){
	var result = Object.keys(data).filter(function(key){
		return data[key] != null && data[key] != "" && key != "email_2";
	});
	this.mysql.query({
		sql: 'UPDATE `users` SET ' + result.map(function(item){
			return "`user_" + item + "` = ?";
		}).join(", ") + ' WHERE `user_email` = ?',
		timeout: 1000,
		values: result.map(function(item){
			return data[item];
		}).concat(data.email_2)
	}, function(err, data){
		err ?
			callback() :
			callback(data || null);
	});
}