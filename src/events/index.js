var Types = require('../constants/eventTypes.js');
Object.keys(Types).forEach(function(key){
	if (key != Types.SET_HASH)
		module.exports[key] = require('./actions/' + key + '.js');
});
