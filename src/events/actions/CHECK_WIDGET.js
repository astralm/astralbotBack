module.exports = function(data, callback){
	this.mysql.query({
		sql: "SELECT `organization_close_widget` FROM `organizations` WHERE `organization_id` = ?",
		values: [
			data.organization_id
		]
	}, function(err, responce){
		err ?
			callback(null) :
			callback(responce || null);
	});
}