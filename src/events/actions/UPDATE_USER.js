module.exports = function(data, callback){
	console.log(data);
	this.mysql.query({
		sql: "SELECT * FROM `users` WHERE `user_email` = ?",
		timeout: 1000,
		values: [
			data
		]
	}, function(err, responce){
		console.log(err, responce);
		err ?
			callback() :
			callback(responce || null);
	});
}