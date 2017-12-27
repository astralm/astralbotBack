module.exports = function(data, callback){
	this.mysql.query({
		sql: 'UPDATE `sessions` SET `session_error` = 0 WHERE `session_hash` = ?',
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