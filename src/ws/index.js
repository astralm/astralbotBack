var Types = require("../constants/eventTypes.js");
function broadcastGetUsers(){
	var _this = this;
	_this.reducer(_this.actions.GET_USERS(), function(response){
		_this.io.sockets.emit(Types.GET_USERS, response);
	});
}
module.exports = function(io, reducer, actions){
	io.on('connection', function(socket){
		broadcastGetUsers = broadcastGetUsers.bind({reducer, actions, io});
		socket.on(Types.LOGIN, function(data){
			socket.email = data.email;
			reducer(actions.LOGIN(data), function(response){
				socket.emit(Types.LOGIN, response);
			});
			reducer(actions.UPDATE_USER(socket.email), function(response){
				socket.emit(Types.UPDATE_USER, response);
			});
			broadcastGetUsers();
		});
		socket.on('disconnect', function(){
			reducer(actions.LOGOUT({email: socket.email}));
			broadcastGetUsers();
		});
		socket.on(Types.LOGOUT, function(){
			reducer(actions.LOGOUT({email: socket.email}), function(response){
				socket.emit(Types.LOGOUT, response);
			});
			broadcastGetUsers();
		});
		socket.on(Types.GET_USERS, function(){
			reducer(actions.GET_USERS(), function(response){
				socket.emit(Types.GET_USERS, response);
			})
		});
		socket.on(Types.SET_USER, function(data){
			reducer(actions.SET_USER(data), function(){
				broadcastGetUsers();
			})
		});
	});
}