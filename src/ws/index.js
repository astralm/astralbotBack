var Types = require("../constants/eventTypes.js");

module.exports = function(io, reducer, actions){
	io.on('connection', function(socket){
		Object.keys(Types).forEach(function(key){
			socket.on(key, function(data){
				reducer(actions[key](data), function(err, responce){
					socket.emit(key, err || responce);
				});
			});
		});
	});
}