module.exports = function(data, callback){
	console.log(data.email);
	this.mysql.query({
		sql: 'UPDATE `users` SET `user_status` = ? WHERE `user_email` = ?',
		timeout: 1000,
		values: [
			0,
			data.email
		]
	}, function(err, data){
		if(callback)
			callback(false);
	});
}