module.exports = function(data, callback){
	this.mysql.query({
		sql: 'INSERT INTO `users` (`user_email`, `user_password`, `user_name`, `organization_id`) VALUES (?, ?, ?, ?)',
		timeout: 1000,
		values: [
			data.email,
			data.password,
			data.name,
			data.organization_id
		]
	}, function(err, responce){
		if(callback){
			err ?
				callback() :
				callback(responce || null);
		}
	});
}