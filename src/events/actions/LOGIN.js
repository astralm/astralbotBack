var SetStatus = require('./SET_STATUS.js');
module.exports = function(data, callback){
	var _this = this;
	_this.data = data;
	this.mysql.query({
		sql: 'INSERT INTO `user_sessions` (`user_id`, `session_id`) SELECT u.user_id, s.session_id FROM `users` AS `u` JOIN sessions AS `s` ON s.session_hash = ? WHERE `user_email` = ? AND `user_password` = ?',
		timeout: 1000,
		values: [
			data.hash,
			data.email,
			data.password
		]
	}, function(err, data){
		if(err)
			callback(); 
		else if(data.affectedRows > 0){
			callback(true);
			SetStatus.call({mysql: _this.mysql}, {status_id: 1, hash: _this.data.hash}, function(){});
		}
		else
			callback();
	});
}