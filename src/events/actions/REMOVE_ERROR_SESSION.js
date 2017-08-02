module.exports = function(data, callback){
	this.mysql.query({
		sql: 'UPDATE `sessions` SET `session_error` = 0 WHERE `session_hash` = ?',
		timeout: 1000,
		values: [
			data
		]
	}, function(err, data){
		if(callback)
			err ?
				callback() :
				callback(data || null);
	});
}