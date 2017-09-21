var Events = require("./events/index.js");
module.exports = function(mysql, transporter){
	return function(action, callback){
		return Events[action.type] ? Events[action.type].call({mysql, transporter}, action.data, callback) : false;
	}
}