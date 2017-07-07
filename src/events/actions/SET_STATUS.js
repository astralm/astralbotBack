module.exports = function(data, callback){
	this.mysql.query({
		sql: 'INSERT INTO `user_status` (user_id, status_id) SELECT usv.user_id, s.status_id FROM `user_sessions_view` AS usv LEFT JOIN `statuses` AS s ON s.status_name = ? WHERE usv.session_hash = ?',
		timeout: 1000,
		values: [
			data.status,
			data.hash
		]
	}, (err, data) => {
		err ? callback("offline") : data.affectedRows > 0 ? callback(data.status) : callback("offline");
	});
}