module.exports = function(data, callback){
	this.mysql.query({
		sql: "SELECT * FROM `users` WHERE `user_notification_hash`=?",
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