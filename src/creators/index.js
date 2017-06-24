var Types = require("../constants/eventTypes.js");
Object.keys(Types).forEach(function(key){
	module.exports[key] = function(data){
		return {
			type: key,
			data: data
		}
	}
})