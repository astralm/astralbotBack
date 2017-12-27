module.exports = function(data, callback){
	this.mysql.query({
		sql: 'SELECT `session_id` FROM `sessions` WHERE `session_hash` = ?',
		values: [
			data
		]
	}, function(err, data){
		err ?
			callback() :
			callback(data || null);
	});
}