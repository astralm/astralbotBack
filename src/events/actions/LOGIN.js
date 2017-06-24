module.exports = function(data, callback){
	this.mysql.query({
		sql: 'INSERT INTO user_sessions (user_id, session_id) SELECT u.user_id, s.session_id FROM users u LEFT JOIN sessions s ON s.session_hash = ? WHERE u.user_email = ? AND u.user_password = ? ',
		timeout: 1000,
		values: [
			data.hash,
			data.email.toLowerCase(),
			data.password
		]
	}, callback);
}