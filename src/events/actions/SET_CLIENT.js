module.exports = function(data, callback){
	var attributesNames = [],
			attributesValues = [],
			attributesSymbols = [];
	for(var i = 0; i < Object.keys(data).length; i++){
		attributesNames.push(Object.keys(data)[i]);
		attributesValues.push(data[Object.keys(data)[i]]);
		attributesSymbols.push("?");
	}
	this.mysql.query({
		sql: "INSERT INTO `clients` ("+attributesNames.join(",")+") VALUES ("+attributesSymbols.join(",")+")",
		timeout: 1000,
		values: attributesValues
	}, function(err, responce){
		if(callback){
			if(err){
				callback();
			} else {
				callback(responce || null);
			}
		}
	})
}