module.exports = function(data, callback){
	this.mysql.query({
		sql: "DELETE FROM `dispatches` WHERE `dispatch_id` = ?",
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
	})
}