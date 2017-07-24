module.exports = function(data, callback){
	this.mysql.query({
		sql: 'SELECT * FROM `sessions_info_view`',
		timeout: 1000
	}, function(err, data){
		err ? 
			callback() :
			callback(data || null);
	});
}