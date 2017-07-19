module.exports = function(data, callback){
	this.mysql.query({
		sql: 'SELECT user_name, user_email, user_status FROM `users`',
		timeout: 1000
	}, function(err, data){
		err ?
			callback() :
			callback(data);
	});
}	