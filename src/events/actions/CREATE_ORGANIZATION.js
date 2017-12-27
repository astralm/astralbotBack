module.exports = function(data, callback){
	this.mysql.query({
		sql: "INSERT INTO `organizations` (`organization_name`, `organization_site`, `organization_root`) VALUES (?,?,?)",
		values: [
			data.organization_name,
			data.organization_site,
			data.organization_root
		]
	}, function(err, responce){
		if(callback){
			err ?
				callback() :
				callback(responce || null);
		}
	});
}