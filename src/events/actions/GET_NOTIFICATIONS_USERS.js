module.exports = function(data, callback){
	this.mysql.query({
		sql: "SELECT * FROM `users` WHERE `organization_id`=? AND `user_notification`=? AND `user_notification_chat` IS NOT NULL",
		timeout: 1000,
		values: [
			data,
			1
		]
	}, function(err, responce){
		if(callback){
			err ?
				callback() :
				callback(responce || null);
		}
	});
}