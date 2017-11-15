module.exports = function(data, callback){
	var hash = [];
	for(var i = 0; i < 32; i++){
		var random = Math.ceil(Math.random() * 2),
				symbol = Math.ceil(Math.random() * 0xF).toString(16);
		random == 1 ?
			hash.push(symbol.toLowerCase()) :
			hash.push(symbol.toUpperCase());
	}
	hash = hash.join("");
	this.mysql.query({
		sql: 'INSERT INTO `users` (`user_email`, `user_password`, `user_name`, `organization_id`, `user_notification_hash`) VALUES (?, ?, ?, ?, ?)',
		timeout: 1000,
		values: [
			data.email,
			data.password,
			data.name,
			data.organization_id,
			hash
		]
	}, function(err, responce){
		if(callback){
			err ?
				callback() :
				callback(responce || null);
		}
	});
}