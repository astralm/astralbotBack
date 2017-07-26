module.exports = function(data, callback){
	this.mysql.query({
		sql: 'SELECT * FROM `sessions_info_view` WHERE `session_error` = 1 LIMIT 50 OFFSET ?',
		timeout: 1000,
		values: [
			+data
		]
	}, function(err, data){
		err ?
			callback() :
			callback(data || null);
	})
}