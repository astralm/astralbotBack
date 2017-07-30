module.exports = function(data, callback){
	this.mysql.query({
		sql: 'SELECT * FROM `session_info_view` WHERE `session_id` = ?',
		timeout: 1000,
		values: [
			+data
		]
	}, function(err, data){
		err ?
			callback() :
			callback(data || null);
	});
}