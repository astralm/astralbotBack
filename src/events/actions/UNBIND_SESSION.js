module.exports = function(data, callback){
	this.mysql.query({
		sql: 'UPDATE `sessions` SET `user_id` = 0 WHERE `session_id` = ? AND `user_id` = ?',
		tiomeout: 1000,
		values: [
			+data.session_id,
			+data.user_id
		]
	}, function(err, data){
		if(callback){
			err ?
				callback() :
				callback(data || null);
		}
	});
}