module.exports = function(data, callback){
	this.mysql.query({
		sql: "SELECT * FROM `clients` WHERE `client_id` = ?",
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