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
		socket.on(Types.GET_SESSIONS, function(data){
			reducer(actions.GET_SESSIONS(data), function(response){
				socket.emit(Types.GET_SESSIONS, response);
			})
		});
		socket.on(Types.GET_USER_SESSIONS, function(data){
			reducer(actions.GET_USER_SESSIONS(data), function(response){
				socket.emit(Types.GET_USER_SESSIONS, response);
			});
		});
		socket.on(Types.GET_FREE_SESSIONS, function(data){
			reducer(actions.GET_FREE_SESSIONS(data), function(response){
				socket.emit(Types.GET_FREE_SESSIONS, response);
			});
		});
		socket.on(Types.GET_BUSY_SESSIONS, function(data){
			reducer(actions.GET_BUSY_SESSIONS(data), function(response){
				socket.emit(Types.GET_BUSY_SESSIONS, response);
			});
		});
		socket.on(Types.GET_ERROR_SESSIONS, function(data){
			reducer(actions.GET_ERROR_SESSIONS(data), function(response){
				socket.emit(Types.GET_ERROR_SESSIONS, response);
			});
		});
		socket.on(Types.GET_SUCCESS_SESSIONS, function(data){
			reducer(actions.GET_SUCCESS_SESSIONS(data), function(response){
				socket.emit(Types.GET_SUCCESS_SESSIONS, response);
			});
		});
		socket.on(Types.GET_ACTIVE_SESSIONS, function(data){
			reducer(actions.GET_ACTIVE_SESSIONS(data), function(response){
				socket.emit(Types.GET_ACTIVE_SESSIONS, response);
			});
		});
		socket.on(Types.GET_INACTIVE_SESSIONS, function(data){
			reducer(actions.GET_INACTIVE_SESSIONS(data), function(response){
				socket.emit(Types.GET_INACTIVE_SESSIONS, response);
			});
		});
	});
}