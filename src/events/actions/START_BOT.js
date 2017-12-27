module.exports = function(data, callback){
	this.mysql.query({
		sql: 'UPDATE `sessions` SET `bot_work` = 1 WHERE `session_id` = ?',
		values: [
			+data
		]
	}, function(err, data){
		if(callback)
			err ?
				callback() :
				callback(data || null);
	});
}