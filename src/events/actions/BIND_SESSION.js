module.exports = function(data, callback){
	this.mysql.query({
		sql: 'UPDATE `sessions` SET `user_id` = ? WHERE `session_id` = ?',
		values: [
			data.user_id,
			data.session_id
		]
	}, function(err, data){
		if(callback){
			err ?
				callback() :
				callback(data || null);
		}
	});
}