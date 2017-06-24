var Events = require("./events/index.js");
module.exports = function(mysql){
	return function(action, callback){
		return Events[action.type] ? Events[action.type].call({mysql}, action.data, callback || function(){}) : false;
	}
}