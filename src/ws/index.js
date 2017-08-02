var Types = require("../constants/eventTypes.js");
function broadcastGetUsers(){
	var _this = this;
	_this.reducer(_this.actions.GET_USERS(), function(response){
		_this.io.sockets.emit(Types.GET_USERS, response);
	});
}
function broadcastGetSessions(){
	var _this = this,
		switches = (function(sockets){
			var res = [];
			for(var socketKey in sockets){
				var socket = sockets[socketKey];
				if (socket.switch && socket.switch != Types.GET_SESSION_DIALOG && socket.switch != Types.GET_SESSION_INFO)
					res.push("s" + socket.switch + "a" + socket.attributes.offset + "u" + (socket.attributes.user_id ? socket.attributes.user_id : ""));
			}
			return res;
		})(_this.io.sockets.sockets).filter(function(str, strKey, self){
			return self.indexOf(str) == strKey;
		}).map(function(str){
			return str.match(/s(.*)a(.*)u(.*)/).filter(function(option, key){
				return [1,2,3].indexOf(key) > -1;
			});
		});
	switches.forEach(function(action, actionKey){
		_this.reducer(_this.actions[action[0]](!action[2] ? action[1] : {offset: action[1], user_id: action[2]}), function(response){
			switches[actionKey].push(response);
			(function(sockets){
				for(var socketKey in sockets){
					var socket = sockets[socketKey];
					socket.emit(socket.switch, switches.filter(function(option){
						return option[0] == socket.switch && 
							   option[1] == socket.attributes.offset && 
								   socket.attributes.user_id ?
								      option[2] == socket.attributes.user_id :
								      true;
					})[0][3]);
				}
			})(_this.io.sockets.sockets);
		});
	});
}
function broadcastGetSessionInfo(session_id){
	var _this = this;
	this.reducer(this.actions.GET_SESSION_INFO(session_id), function(response){
		for(var socketKey in _this.io.sockets.sockets){
			var socket = _this.io.sockets.sockets[socketKey];
			if((socket.switch == Types.GET_SESSION_INFO || socket.switch == Types.GET_SESSION_DIALOG) && socket.attributes.session_id == session_id)
				socket.emit(Types.GET_SESSION_INFO, response);
		}
	});
}
function broadcastGetSessionsDialog(data){
	var _this = this;
	this.reducer(this.actions.GET_SESSION_DIALOG(data), function(response){
		for(var socketKey in _this.io.sockets.sockets){
			var socket = _this.io.sockets.sockets[socketKey];
			if((socket.switch == Types.GET_SESSION_INFO || socket.switch == Types.GET_SESSION_DIALOG) && (data.session_id ? socket.attributes.session_id == data.session_id : socket.attributes.session_hash == data.session_hash))
				socket.emit(Types.GET_SESSION_DIALOG, response);
		}
	});
}
module.exports = function(io, reducer, actions, telegram){
	io.broadcastGetUsers = broadcastGetUsers.bind({reducer, actions, io});
	io.broadcastGetSessions = broadcastGetSessions.bind({reducer, actions, io});
	io.broadcastGetSessionInfo = broadcastGetSessionInfo.bind({reducer, actions, io});
	io.broadcastGetSessionsDialog = broadcastGetSessionsDialog.bind({reducer, actions, io});
	io.on('connection', function(socket){
		socket.on(Types.LOGIN, function(data){
			socket.email = data.email;
			socket.switch = "";
			reducer(actions.LOGIN(data), function(response){
				socket.emit(Types.LOGIN, response);
				io.broadcastGetUsers();
			});
			reducer(actions.UPDATE_USER(socket.email), function(response){
				socket.emit(Types.UPDATE_USER, response);
			});
		});
		socket.on('disconnect', function(){
			reducer(actions.LOGOUT({email: socket.email}));
			io.broadcastGetUsers();
		});
		socket.on(Types.LOGOUT, function(){
			socket.switch = "";
			reducer(actions.LOGOUT({email: socket.email}), function(response){
				socket.emit(Types.LOGOUT, response);
			});
			io.broadcastGetUsers();
		});
		socket.on(Types.GET_USERS, function(){
			socket.switch = "";
			reducer(actions.GET_USERS(), function(response){
				socket.emit(Types.GET_USERS, response);
			})
		});
		socket.on(Types.SET_USER, function(data){
			socket.switch = "";
			reducer(actions.SET_USER(data), function(){
				io.broadcastGetUsers();
			})
		});
		socket.on(Types.GET_SESSIONS, function(data){
			socket.switch = Types.GET_SESSIONS;
			socket.attributes = {
				offset: data
			};
			reducer(actions.GET_SESSIONS(data), function(response){
				socket.emit(Types.GET_SESSIONS, response);
			});
		});
		socket.on(Types.GET_USER_SESSIONS, function(data){
			socket.switch = Types.GET_USER_SESSIONS;
			socket.attributes = {
				offset: data.offset,
				user_id: data.user_id
			};
			reducer(actions.GET_USER_SESSIONS(data), function(response){
				socket.emit(Types.GET_USER_SESSIONS, response);
			});
		});
		socket.on(Types.GET_FREE_SESSIONS, function(data){
			socket.switch = Types.GET_FREE_SESSIONS;
			socket.attributes = {
				offset: data
			};
			reducer(actions.GET_FREE_SESSIONS(data), function(response){
				socket.emit(Types.GET_FREE_SESSIONS, response);
			});
		});
		socket.on(Types.GET_BUSY_SESSIONS, function(data){
			socket.switch = Types.GET_BUSY_SESSIONS;
			socket.attributes = {
				offset: data
			};
			reducer(actions.GET_BUSY_SESSIONS(data), function(response){
				socket.emit(Types.GET_BUSY_SESSIONS, response);
			});
		});
		socket.on(Types.GET_ERROR_SESSIONS, function(data){
			socket.switch = Types.GET_ERROR_SESSIONS;
			socket.attributes = {
				offset: data
			};
			reducer(actions.GET_ERROR_SESSIONS(data), function(response){
				socket.emit(Types.GET_ERROR_SESSIONS, response);
			});
		});
		socket.on(Types.GET_SUCCESS_SESSIONS, function(data){
			socket.switch = Types.GET_SUCCESS_SESSIONS;
			socket.attributes = {
				offset: data
			};
			reducer(actions.GET_SUCCESS_SESSIONS(data), function(response){
				socket.emit(Types.GET_SUCCESS_SESSIONS, response);
			});
		});
		socket.on(Types.GET_ACTIVE_SESSIONS, function(data){
			socket.switch = Types.GET_ACTIVE_SESSIONS;
			socket.attributes = {
				offset: data
			};
			reducer(actions.GET_ACTIVE_SESSIONS(data), function(response){
				socket.emit(Types.GET_ACTIVE_SESSIONS, response);
			});
		});
		socket.on(Types.GET_INACTIVE_SESSIONS, function(data){
			socket.switch = Types.GET_INACTIVE_SESSIONS;
			socket.attributes = {
				offset: data
			};
			reducer(actions.GET_INACTIVE_SESSIONS(data), function(response){
				socket.emit(Types.GET_INACTIVE_SESSIONS, response);
			});
		});
		socket.on(Types.BIND_SESSION, function(data){
			reducer(actions.BIND_SESSION(data), function(response){
				io.broadcastGetSessions();
				io.broadcastGetSessionInfo(data.session_id);
			});
		});
		socket.on(Types.UNBIND_SESSION, function(data){
			reducer(actions.UNBIND_SESSION(data), function(response){
				io.broadcastGetSessions();
				io.broadcastGetSessionInfo(data.session_id);
			});
		});
		socket.on(Types.GET_SESSION_INFO, function(data){
			socket.switch = Types.GET_SESSION_INFO;
			socket.attributes = {
				session_id: data
			};
			reducer(actions.GET_SESSION_INFO(data), function(response){
				socket.emit(Types.GET_SESSION_INFO, response);
			});
		});
		socket.on(Types.GET_SESSION_DIALOG, function(data){
			socket.switch = Types.GET_SESSION_DIALOG;
			socket.attributes = {
				session_id: data
			};
			reducer(actions.GET_SESSION_DIALOG({session_id: data}), function(response){
				socket.emit(Types.GET_SESSION_DIALOG, response);
				socket.attributes.session_hash = (response ? response[0].session_hash : null);
			});
		});
		socket.on(Types.SET_ANSWER, function(data){
			reducer(actions.SET_ANSWER(data), function(response){
				io.broadcastGetSessionsDialog({session_id: data.session_id});
				io.broadcastGetSessionInfo(data.session_id);
				io.broadcastGetSessions();
				telegram.sendMessage(data.hash, data.message);
			});
		});
		socket.on(Types.START_BOT, function(data){
			reducer(actions.START_BOT(data), function(response){
				reducer(actions.GET_SESSION_INFO(data), function(response){
					telegram.connections.find(function(connection){
						return connection.session_hash == response.session_hash;
					}).bot = true;
				});
			});
		});
		socket.on(Types.STOP_BOT, function(data){
			reducer(actions.STOP_BOT(data), function(response){
				reducer(actions.GET_SESSION_INFO(data), function(response){
					telegram.connections.find(function(connection){
						return connection.session_hash == response.session_hash;
					}).bot = false;
				});
			});
		});
	});
}