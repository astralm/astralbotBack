var Types = require('../constants/eventTypes.js');
module.exports = function(rest, reducer, actions){
	Object.keys(Types).map(function(key){
		rest.get(key, function(req, res){
			reducer(actions[key](req.params), function(data){
				res.send(data);
			});
		});
	});
}