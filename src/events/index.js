var Types = require('../constants/eventTypes.js');
Object.keys(Types).forEach(function(key){
	module.exports[key] = require('./actions/' + key + '.js');
});
