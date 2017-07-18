var Types = require("../constants/eventTypes.js");
module.exports = function(io, reducer, actions){
	io.on('connection', function(socket){
		socket.on(Types.LOGIN, function(data){
			reducer(actions.LOGIN(data), function(response){
				socket.emit(Types.LOGIN, response);
			})
		})
	});
}