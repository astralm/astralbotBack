module.exports = function(data, callback){
	this.mysql.query({
		sql: "SELECT `client_id` FROM `clients` WHERE `session_id` = ?",
		timeout: 1000,
		values: [
			data
		]
	}, function(err, responce){
		if(callback){
			err ?
				callback() :
				callback(responce || null);
		}
	});
}