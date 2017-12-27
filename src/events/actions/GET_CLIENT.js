module.exports = function(data, callback){
	this.mysql.query({
		sql: "SELECT * FROM `clients` WHERE `client_id` = ?",
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