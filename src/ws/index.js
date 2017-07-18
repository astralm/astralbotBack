var Types = require("../constants/eventTypes.js");
module.exports = function(io, reducer, actions){
	io.on('connection', function(socket){
		socket.on(Types.LOGIN, function(data){
			socket.email = data.email;
			reducer(actions.LOGIN(data), function(response){
				socket.emit(Types.LOGIN, response);
			})
		});
		socket.on('disconnect', function(){
			reducer(actions.LOGOUT({email: socket.email}));
		});
		socket.on(Types.LOGOUT, function(){
			reducer(actions.LOGOUT({email: socket.email}), function(response){
				socket.emit(Types.LOGOUT, response);
			})
		});
	});
}