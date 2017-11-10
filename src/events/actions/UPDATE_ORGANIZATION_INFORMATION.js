module.exports = function(data, callback){
	var result = Object.keys(data).filter(function(key){
		return data[key] !== null && data[key] !== "" && key != "organization_id";
	});
	console.log(result, data);
	this.mysql.query({
		sql: 'UPDATE `organizations` SET ' + result.map(function(item){
			return "`" + item + "` = ?";
		}).join(", ") + ' WHERE `organization_id` = ?',
		timeout: 1000,
		values: result.map(function(item){
			return data[item].toString();
		}).concat(data.organization_id)
	}, function(err, responce){
		console.log(err, responce);
		err ?
			callback() :
			callback(responce || null);
	});
}