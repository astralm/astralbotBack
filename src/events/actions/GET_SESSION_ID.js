module.exports = function(data, callback){
	this.mysql.query({
		sql: 'SELECT `session_id` FROM `sessions` WHERE `session_hash` = ?',
		timeout: 1000,
		values: [
			data
		]
	}, function(err, data){
		err ?
			callback() :
			callback(data || null);
	});
}