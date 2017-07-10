var status;
module.exports = function(data, callback){
	status = data.status_id;
	this.mysql.query({
		sql: 'INSERT INTO `user_statuses` (`user_id`, `status_id`) SELECT user_id, ? FROM `user_sessions_status_view` WHERE session_hash = ?',
		tiomeout: 1000,
		values: [
			data.status_id,
			data.hash
		]
	}, function(err, data){
		err ?
			callback() :
			data.affectedRows > 0 ?
				callback(status) :
				callback()
	})
}