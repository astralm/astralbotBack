module.exports = function(data, callback){
	this.mysql.query({
		sql: "UPDATE organizations SET organization_close_widget = ? WHERE organization_id = ?",
		values: [
			data.param,
			data.organization_id
		]
	}, function(err, responce){
		err ?
			callback() :
			callback(responce);
	});
}