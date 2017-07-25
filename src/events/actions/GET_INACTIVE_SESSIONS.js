module.exports = function(data, callback){
	this.mysql.query({
		sql: 'SELECT * FROM `sessions_info_view` WHERE `session_status` = 0 LIMIT 50 OFFSET ?',
		timeout: 1000,
		values: [
			data
		]
	}, function(err, data){
		err ?
			callback() :
			callback(data || null);
	})
}