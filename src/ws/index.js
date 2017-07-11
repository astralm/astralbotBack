var Types = require("../constants/eventTypes.js");

module.exports = function(io, reducer, actions){
	io.on('connection', function(socket){
		reducer(actions[Types.HASH](), function(data){
			if(data != null){
				socket.emit(Types.HASH, data);
				socket.hash = data;
			}
		});
		socket.on('disconnect', function(){
			reducer(actions[Types.SET_STATUS]({
				status_id: 2,
				hash: socket.hash
			}), function(){});
		});
		Object.keys(Types).forEach(function(key){
			socket.on(key, function(data){
				reducer(actions[key](data), function(err, responce){
					socket.emit(key, err || responce);
				});
			});
		});
	});
}