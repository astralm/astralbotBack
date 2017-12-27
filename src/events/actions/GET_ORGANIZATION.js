module.exports = function(data, callback){
	this.mysql.query({
		sql: "SELECT * FROM `organizations` WHERE `organization_id` = ?",
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