module.exports = function(data, callback){
	this.mysql.query({
		sql: "SELECT * FROM `sessions_info_view` WHERE `organization_id`=?",
		timeout: 1000,
		values: [
			data
		]
	}, function(err, responce){
		console.log(err, responce);
		if(callback){
			err ?
				callback() :
				callback(responce || null);
		}
	});
}