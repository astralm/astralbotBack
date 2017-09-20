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
function broadcastGetSessions(){
	var sockets = this.io.sockets.sockets,
		options = [];
	for (var key in sockets){
		var socket = sockets[key];
		if(socket.switch == Types.GET_SESSIONS){
			var attributes = socket.hasOwnProperty("attributes") ? socket.attributes : false,
				filters = attributes ? attributes.filters.sort().join(",") : "",
				order = attributes ? attributes.order : {name: "session_id", desc: true},
				offset = attributes ? +attributes.offset : 0,
				user_id = attributes ? +attributes.user_id : 0;
			if(options.length > 0){
				for (var i = 0; i < options.length; i++){
					var option = options[i],
						_filters = option.filters.sort().join(","),
						_order = option.order,
						_offset = option.offset;
					if(_filters != filters || _order.name != order.name || _order.desc != order.desc || _offset != offset){
						options.push({
							filters: filters ? socket.attributes.filters : [],
							order: order,
							offset: offset,
							objects: [socket]
						});
					} else {
						option.objects.push(socket);
					}
				}
			} else {
				options.push({
					filters: filters ? socket.attributes.filters : [],
					order: order,
					offset: offset,
					objects: [socket]
				});
			}
		}
	}
	if(options.length > 0){
		for(var i = 0; i < options.length; i++){
			var option = options[i];
			if(option.filters.indexOf("user") != -1){
				for(var l = 0; l < option.objects.length; l++){
					var user_id = option.objects[l].attributes.user_id;
					this.reducer(this.actions[Types.GET_SESSIONS]({
						filters: option.filters,
						order: option.order,
						offset: option.offset,
						user_id: user_id
					}), (function(key, object, response){
						if(object.objects[key]){
							object.objects[key].emit(Types.GET_SESSIONS, response);
						}
					}).bind(this, l, option));
				}
			} else {
				this.reducer(this.actions[Types.GET_SESSIONS]({
					filters: option.filters,
					order: option.order,
					offset: option.offset
				}), (function(object, response){
					for(var j = 0; j < object.objects.length; j++){
						if(object.objects[j]){
							object.objects[j].emit(Types.GET_SESSIONS, response);
						}
					}
				}).bind(this, option));
			}
		}
	}
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
				if(response){
					reducer(actions.UPDATE_USER(socket.email), function(response){
						if(response && response[0]){
							socket.user_id = response[0].user_id;
						}
						socket.emit(Types.UPDATE_USER, response);
					});
					io.broadcastGetUsers();
				}
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
			if(!socket.hasOwnProperty("attributes")){
				socket.attributes = {
					filters: [],
					user_id: socket.user_id
				};
			}
			socket.attributes.offset = data.offset;
			socket.attributes.order = data.order;
			var key = socket.attributes.filters.indexOf(data.filter);
			if(data.filter){
				if(data.filter != "all"){
					switch(data.filter){
						case 'active':
						case 'inactive': 
							var filterKey = socket.attributes.filters.indexOf(data.filter == 'active' ? 'inactive' : 'active');
							break;
						case 'error':
						case 'success':
							var filterKey = socket.attributes.filters.indexOf(data.filter == 'error' ? 'success' : 'error');
							break;
						case 'free':
						case 'busy':
							var filterKey = socket.attributes.filters.indexOf(data.filter == 'free' ? 'busy' : 'free');
							break;
						case 'user':
							var filterKey = socket.attributes.filters.indexOf('free');
							break;
					}
					if(filterKey > -1){
						socket.attributes.filters.splice(filterKey, 1);
					}
					if(key >= 0){
						socket.attributes.filters.splice(key, 1);
					} else {
						socket.attributes.filters.push(data.filter);
					}
				} else {
					socket.attributes.filters = [];
				}
			}
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
				reducer(actions[Types.START_BOT](data.session_id), function(){
					reducer(actions.GET_BOT_STATUS({session_id: data.session_id}), function(status){
						socket.emit(Types.GET_BOT_STATUS, status);
					});
				});
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
			reducer(actions[Types.GET_SESSION_INFO](data.session_id), function(response){
				response = response[0] || {};
				if(response.session_error){
					reducer(actions[Types.REMOVE_ERROR_SESSION](response.session_hash), function(){
						io.broadcastGetSessionInfo(response.session_id);
						io.broadcastGetSessions();
					});
				}
			});
		});
		socket.on(Types.START_BOT, function(data){
			reducer(actions.START_BOT(data), function(response){
				reducer(actions.GET_BOT_STATUS({session_id: data}), function(response){
					socket.emit(Types.GET_BOT_STATUS, response);
				});
			});
		});
		socket.on(Types.STOP_BOT, function(data){
			reducer(actions.STOP_BOT(data), function(response){
				reducer(actions.GET_BOT_STATUS({session_id: data}), function(response){
					socket.emit(Types.GET_BOT_STATUS, response);
				})
			});
		});
		socket.on(Types.GET_BOT_STATUS, function(data){
			reducer(actions[Types.GET_BOT_STATUS](data), function(response){
				socket.emit(Types.GET_BOT_STATUS, response);
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
				io.broadcastGetSessions();
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
				socket.attributes.session_id = response[0].session_id;
				reducer(actions.SET_ACTIVE({session_hash: data}), function(){
					io.broadcastGetSessions();
					console.log(socket.attributes);
					io.broadcastGetSessionInfo(socket.attributes.session_id);
				});
			});
		});
		socket.on("WIDGET_MESSAGE", function(data){
			reducer(actions.SET_QUESTION({message: data, hash: socket.token}), function(response){
				reducer(actions.GET_BOT_STATUS({session_hash: socket.token}), function(bot_status_response){
					var bot_status = bot_status_response[0].bot_work;
					if(bot_status){
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
							io.broadcastGetSessionInfo(socket.attributes.session_id);
						});
						setTimeout(function(){
							request.end();
						}, 7000);
					}
					socket.attributes.session_hash = socket.token;
					io.broadcastGetSessionInfo(socket.attributes.session_id);
					io.broadcastGetSessionsDialog({session_hash: socket.token});
					io.broadcastGetSessions();
				});
			});
		});
		socket.on(Types.REMOVE_ERROR_SESSION, function(data){
			reducer(actions[Types.REMOVE_ERROR_SESSION](data.session_hash), function(){
				io.broadcastGetSessions();
				io.broadcastGetSessionInfo(data.session_id);
			});
		});
	});
}