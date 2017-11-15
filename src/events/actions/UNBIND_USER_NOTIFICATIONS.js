module.exports = function(data, callback){
	this.mysql.query({
		sql: "UPDATE `users` SET `user_notification`=? WHERE `user_notification_chat`=?",
		timeout: 1000,
		values: [
			0,
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