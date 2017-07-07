module.exports = function(data, callback){
	this.mysql.query({
		sql: 'INSERT INTO `user_sessions` (user_id, session_id) SELECT u.user_id, s.session_id FROM `users` AS `u` LEFT JOIN `sessions` AS `s` ON s.session_hash = ? WHERE u.user_email = ? AND u.user_password = ?',
		timeout: 1000,
		values: [
			data.hash,
			data.email,
			data.password
		] 
	}, function(err, data){
		err ? callback() : data.affectedRows > 0 ? callback(true) : callback();
	})
}