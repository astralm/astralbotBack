module.exports = function(data, callback){
	this.mysql.query({
		sql: "SELECT `o`.* FROM `organizations` `o` JOIN `users` `u` ON `u`.`organization_id` = `o`.`organization_id` WHERE `u`.`user_id` = ?",
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