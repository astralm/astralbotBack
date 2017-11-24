module.exports = function(data, callback){
	this.mysql.query({
		sql: 'SELECT * FROM `session_info_view` WHERE `session_id` = ?',
		values: [
			+data
		]
	}, function(err, data){
		err ?
			callback() :
			callback(data || null);
	});
}