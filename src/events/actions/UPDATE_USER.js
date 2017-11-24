module.exports = function(data, callback){
	this.mysql.query({
		sql: "SELECT * FROM `users` WHERE `user_email` = ?",
		values: [
			data
		]
	}, function(err, responce){
		err ?
			callback() :
			callback(responce || null);
	});
}