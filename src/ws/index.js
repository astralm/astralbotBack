var Types = require("../constants/eventTypes.js");
function broadcastGetUsers(){
	var _this = this;
	_this.reducer(_this.actions.GET_USERS(), function(response){
		_this.io.sockets.emit(Types.GET_USERS, response);
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
function broadcastGetSessions(data){
	
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
module.exports = function(io, reducer, actions, telegram, apiai){
	io.broadcastGetUsers = broadcastGetUsers.bind({reducer, actions, io});
	io.broadcastGetSessions = broadcastGetSessions.bind({reducer, actions, io});
	io.broadcastGetSessionInfo = broadcastGetSessionInfo.bind({reducer, actions, io});
	io.broadcastGetSessionsDialog = broadcastGetSessionsDialog.bind({reducer, actions, io});
	io.on('connection', function(socket){
		socket.bot = true;
		socket.on(Types.LOGIN, function(data){
			socket.email = data.email;
			socket.switch = "";
			reducer(actions.LOGIN(data), function(response){
				socket.emit(Types.LOGIN, response);
				io.broadcastGetUsers();
			});
			reducer(actions.UPDATE_USER(socket.email), function(response){
				if(response && response[0]){
					socket.user_id = response[0].user_id;
				}
				socket.emit(Types.UPDATE_USER, response);
			});
		});
		socket.on('disconnect', function(){
			if(socket.email){
				reducer(actions.LOGOUT({email: socket.email}));
				io.broadcastGetUsers();
			}
			if(socket.type == "widget"){
				reducer(actions.SET_INACTIVE({session_hash: socket.attributes.session_hash || socket.token, session_id: socket.attributes.session_id}), function(){
					io.broadcastGetSessions();
					io.broadcastGetSessionInfo(socket.attributes.session_id);
				});
			}
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
				offset: data.offset,
				filters: Array.apply(this, data.filters),
				order: {
					name: data.order.name,
					desc: data.order.desc
				},
				user_id: socket.user_id
			};
			data.user_id = socket.user_id;
			reducer(actions.GET_SESSIONS(data), function(response){
				socket.emit(Types.GET_SESSIONS, response);
			});
		});
		socket.on("SET_FILTER", function(data){
			socket.attributes.offset = data.offset;
			socket.attributes.order = data.order;
			var key = socket.attributes.filters.indexOf(data.filter);
			if(data.filter != "all"){
				if(key >= 0){
					socket.attributes.filters.splice(key, 1);
				} else {
					socket.attributes.filters.push(data.filter);
				}
			} else {
				socket.attributes.filters = [];
			}
			console.log(socket.attributes.filters, data.filter, key);
			reducer(actions.GET_SESSIONS(socket.attributes), function(response){
				socket.emit(Types.GET_SESSIONS, response);
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
				socket.attributes.session_hash = (response ? response[0] ? response[0].session_hash : null : null);
			});
		});
		socket.on(Types.SET_ANSWER, function(data){
			reducer(actions.SET_ANSWER(data), function(response){
				io.broadcastGetSessionsDialog({session_id: data.session_id});
				io.broadcastGetSessionInfo(data.session_id);
				io.broadcastGetSessions();
				if(data.hash.length < 32){
					telegram.sendMessage(data.hash, data.message);
				}
			});
		});
		socket.on(Types.START_BOT, function(data){
			reducer(actions.START_BOT(data), function(response){
				reducer(actions.GET_SESSION_INFO(data), function(response){
					if(response.session_hash < 32){
						telegram.connections.find(function(connection){
							return connection.session_hash == response.session_hash;
						}).bot = true;
					} else {
						for(var key in io.sockets.sockets){
							var item = io.sockets.sockets[key];
							if (item.attributes && item.attributes.session_id && item.attributes.session_id == data) {
								item.bot = true
							}
						}
					}
				});
			});
		});
		socket.on(Types.STOP_BOT, function(data){
			reducer(actions.STOP_BOT(data), function(response){
				reducer(actions.GET_SESSION_INFO(data), function(response){
					if(response.session_hash < 32){
						telegram.connections.find(function(connection){
							return connection.session_hash == response.session_hash;
						}).bot = false;
					} else {
						for(var key in io.sockets.sockets){
							var item = io.sockets.sockets[key];
							if (item.attributes && item.attributes.session_id && item.attributes.session_id == data) {
								item.bot = false;
							}
						}
					}
				});
			});
		});
		socket.on(Types.UPDATE_USER_INFORMATION, function(data){
			data.email_2 = socket.email;
			reducer(actions.UPDATE_USER_INFORMATION(data), function(response){
				reducer(actions.GET_USER(data.email != null && data.email != '' ? data.email : socket.email), function(response){
					socket.emit(Types.UPDATE_USER, response);
					io.broadcastGetUsers();
					io.broadcastGetSessions();
				});
			});
		});
		socket.on("WIDGET_GET_TOKEN", function(data){
			socket.type = "widget";
			if(!socket.token){
				var random = [],
					number = Math.ceil(Math.random()*2);
				for(var i = 0; i < 32; i++){
					var symbol = (Math.random()*0xFFFFFF).toString(16)[0];
					random.push(Math.ceil(Math.random()*2) == number ? symbol.toLowerCase() : symbol.toUpperCase());
				}
				socket.token = random.join("");
			}
			reducer(actions.SET_SESSION(socket.token), function(response){
				socket.emit("WIDGET_SET_TOKEN", socket.token);
			});
		});
		socket.on(Types.GET_SESSION_ID, function(data){
			socket.token = data;
			socket.type = "widget";
			socket.switch = Types.GET_SESSION_DIALOG;
			socket.attributes = {
				session_hash: data
			};
			reducer(actions.GET_SESSION_ID(data), function(response){
				socket.emit(Types.GET_SESSION_ID, response);
				socket.attributes.session_id = response;
				reducer(actions.SET_ACTIVE({session_hash: data}), function(){
					io.broadcastGetSessions();
					io.broadcastGetSessionInfo(socket.attributes.session_id);
				});
			});
		});
		socket.on("WIDGET_MESSAGE", function(data){
			reducer(actions.SET_QUESTION({message: data, hash: socket.token}), function(response){
				if(socket.bot){
					var request = apiai.textRequest(data, {sessionId: socket.token});
					request.on('response', function(response){
						reducer(actions.SET_ANSWER({hash: socket.token, message: response.result.fulfillment.speech}));
						if(response.result.action == 'input.unknown'){
							reducer(actions.SET_ERROR_SESSION(socket.token));
						} else if (response.result.action != 'input.unknown'){
							reducer(actions.REMOVE_ERROR_SESSION(socket.token));
						}
						io.broadcastGetSessionsDialog({session_hash: socket.token});
						io.broadcastGetSessions();
					});
					request.end();
				}
				socket.attributes.session_hash = socket.token;
				io.broadcastGetSessionInfo(socket.token);
				io.broadcastGetSessionsDialog({session_hash: socket.token});
				io.broadcastGetSessions();
			});
		});
	});
}