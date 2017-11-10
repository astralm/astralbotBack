module.exports = function(data, callback){
	this.mysql.query({
		sql: 'SELECT user_name, user_email, user_status, user_id FROM `users` WHERE `organization_id` = ?',
		timeout: 1000,
		values: [
			data
		]
	}, function(err, data){
		err ?
			callback() :
			callback(data);
	});
}	