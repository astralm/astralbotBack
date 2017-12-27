module.exports = function(data, callback){
	this.mysql.query({
		sql: "UPDATE `users` SET `user_notification`=?, `user_notification_chat`=? WHERE `user_id`=?",
		values: [
			1,
			data.chat_id,
			data.user_id
		]
	}, function(err, responce){
		if(callback){
			err ?
				callback() :
				callback(responce || null);
		}
	});
}