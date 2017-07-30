module.exports = function(data, callback){
	this.mysql.query({
		sql: 'INSERT INTO `users` (`user_email`, `user_password`, `user_name`) VALUES (?, ?, ?)',
		timeout: 1000,
		values: [
			data.email,
			data.password,
			data.name
		]
	}, function(err, data){
		
	});
}