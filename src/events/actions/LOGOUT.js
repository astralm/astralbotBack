module.exports = function(data, callback){
	this.mysql.query({
		sql: 'UPDATE `users` SET `user_status` = ? WHERE `user_email` = ?',
		values: [
			0,
			data.email
		]
	}, function(err, data){
		if(callback)
			callback(false);
	});
}