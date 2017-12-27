module.exports = function(data, callback){
	this.mysql.query({
		sql: 'UPDATE `users` SET `user_status` = ? WHERE `user_email` = ? AND `user_password` = ?',
		values: [
			1,
			data.email,
			data.password
		]
	}, function(err, data){
		callback(err ? null : !data.affectedRows || data.affectedRows <= 0 ? null : true);
	})
}