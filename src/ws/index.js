var Types = require("../constants/eventTypes.js");
function broadcastGetUsers(organization_id){
	var _this = this;
	_this.reducer(_this.actions.GET_USERS(organization_id), function(response){
		for(var socketKey in _this.io.sockets.sockets){
			var socket = _this.io.sockets.sockets[socketKey];
			if(socket.switch == Types.GET_USERS && socket.organization_id == organization_id){
				socket.emit(Types.GET_USERS, response);
			}
		}
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
function broadcastGetSessions(organization_id){
	var sockets = this.io.sockets.sockets,
		options = [];
	for (var key in sockets){
		var socket = sockets[key];
		if(socket.switch == Types.GET_SESSIONS && socket.organization_id == organization_id){
			var attributes = socket.hasOwnProperty("attributes") ? socket.attributes : false,
				filters = attributes ? attributes.filters.sort().join(",") : "",
				order = attributes ? attributes.order : {name: "session_id", desc: true},
				offset = attributes ? +attributes.offset : 0,
				user_id = attributes ? +attributes.user_id : 0,
				firstDate = attributes ? attributes.firstDate : null,
				secondDate = attributes ? attributes.secondDate : null;
			if(options.length > 0){
				for (var i = 0; i < options.length; i++){
					var option = options[i],
						_filters = option.filters.sort().join(","),
						_order = option.order,
						_offset = option.offset,
						_firstDate = option.firstDate,
						_secondDate = option.secondDate;
					if(_filters != filters || _order.name != order.name || _order.desc != order.desc || _offset != offset || _firstDate != firstDate || _secondDate != secondDate){
						options.push({
							filters: filters ? socket.attributes.filters : [],
							order: order,
							offset: offset,
							objects: [socket],
							firstDate: firstDate,
							secondDate: secondDate
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
					firstDate: firstDate,
					secondDate: secondDate,
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
						user_id: user_id,
						firstDate: option.firstDate,
						secondDate: option.secondDate,
						organization_id: organization_id
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
					offset: option.offset,
					firstDate: option.firstDate,
					secondDate: option.secondDate,
					organization_id: organization_id
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
function broadcastGetDispatches(organization_id){
	var _this = this;
	this.reducer(this.actions[Types.GET_DISPATCHES](organization_id), function(response){
		for(var socketKey in _this.io.sockets.sockets){
			var socket = _this.io.sockets.sockets[socketKey];
			if(socket.switch == Types.GET_DISPATCHES && socket.organization_id == organization_id){
				socket.emit(Types.GET_DISPATCHES, response);
			}
		}
	});
}
function broadcastGetClient(client_id){
	var _this = this;
	this.reducer(this.actions[Types.GET_CLIENT](client_id), function(response){
		for(var socketKey in _this.io.sockets.sockets){
			var socket = _this.io.sockets.sockets[socketKey];
			if(socket.switch == Types.GET_CLIENT && socket.client_id == client_id){
				socket.emit(Types.GET_CLIENT, response);
			}
		}
	});
}
function broadcastGetClients(organization_id){
	var _this = this;
	this.reducer(this.actions[Types.GET_CLIENTS](organization_id), function(response){
		for(var socketKey in _this.io.sockets.sockets){
			var socket = _this.io.sockets.sockets[socketKey];
			if(socket.switch == Types.GET_CLIENTS && socket.organization_id == organization_id){
				socket.emit(Types.GET_CLIENTS, response);
			}
		}
	});
}
function broadcastGetOrganizations(){
	var _this = this;
	this.reducer(this.actions[Types.GET_ORGANIZATIONS](), function(response){
		for(var socketKey in _this.io.sockets.sockets){
			var socket = _this.io.sockets.sockets[socketKey];
			if(socket.switch == Types.GET_ORGANIZATIONS){
				socket.emit(Types.GET_ORGANIZATIONS, response);
			}
		}
	});
}
function broadcastGetOrganization(organization_id){
	var _this = this;
	this.reducer(this.actions[Types.GET_ORGANIZATION](organization_id), function(response){
		for(var socketKey in _this.io.sockets.sockets){
			var socket = _this.io.sockets.sockets[socketKey];
			if(socket.switch == Types.GET_ORGANIZATION && socket.organization_id == organization_id){
				socket.emit(Types.GET_ORGANIZATION, response);
			}
		}
	});
}
module.exports = function(io, reducer, actions, ua, telegram, apiai){
	io.broadcastGetUsers = broadcastGetUsers.bind({reducer, actions, io});
	io.broadcastGetSessions = broadcastGetSessions.bind({reducer, actions, io});
	io.broadcastGetSessionInfo = broadcastGetSessionInfo.bind({reducer, actions, io});
	io.broadcastGetSessionsDialog = broadcastGetSessionsDialog.bind({reducer, actions, io});
	io.broadcastGetDispatches = broadcastGetDispatches.bind({reducer, actions, io});
	io.broadcastGetClient = broadcastGetClient.bind({reducer, actions, io});
	io.broadcastGetClients = broadcastGetClients.bind({reducer, actions, io});
	io.broadcastGetOrganizations = broadcastGetOrganizations.bind({reducer, actions, io});
	io.broadcastGetOrganization = broadcastGetOrganization.bind({reducer, actions, io});
	io.on('connection', function(socket){
		socket.attributes = {};
		socket.bot = true;
		socket.on(Types.LOGIN, function(data){
			socket.email = data.email;
			socket.switch = "";
			reducer(actions.LOGIN(data), function(responce){
				if(responce){
					reducer(actions.UPDATE_USER(socket.email), function(response){
						if(response && response[0]){
							socket.user_id = response[0].user_id;
							socket.organization_id = response[0].organization_id;
							socket.email = response[0].user_email;
						}
						socket.emit(Types.UPDATE_USER, response);
						socket.emit(Types.LOGIN, responce);
						io.broadcastGetUsers(socket.organization_id);
						reducer(actions[Types.GET_ORGANIZATION](response[0].organization_id), function(responce){
							socket.emit(Types.GET_USER_ORGANIZATION, responce[0]);
						});
					});
				}
			});
		});
		socket.on('disconnect', function(){
			if(socket.email){
				reducer(actions.LOGOUT({email: socket.email}));
				io.broadcastGetUsers(socket.organization_id);
			}
			if(socket.type == "widget"){
				reducer(actions.SET_INACTIVE({session_hash: socket.attributes.session_hash || socket.token, session_id: socket.attributes.session_id}), function(){
					io.broadcastGetSessions(socket.organization_id);
					io.broadcastGetSessionInfo(socket.attributes.session_id);
				});
			}
		});
		socket.on(Types.LOGOUT, function(){
			socket.switch = "";
			reducer(actions.LOGOUT({email: socket.email}), function(response){
				socket.emit(Types.LOGOUT, response);
			});
			io.broadcastGetUsers(socket.organization_id);
		});
		socket.on(Types.GET_USERS, function(data){
			socket.switch = Types.GET_USERS;
			reducer(actions.GET_USERS(data), function(response){
				socket.emit(Types.GET_USERS, response);
			});
		});
		socket.on(Types.SET_USER, function(data){
			socket.switch = "";
			reducer(actions.SET_USER(data), function(){
				io.broadcastGetUsers(socket.organization_id);
			})
		});
		socket.on(Types.GET_SESSIONS, function(data){
			socket.switch = Types.GET_SESSIONS;
			socket.attributes.offset = data.offset;
			socket.attributes.filters = Array.apply(this, data.filters);
			socket.attributes.order = {
				name: data.order.name,
				desc: data.order.desc
			};
			socket.attributes.user_id = socket.user_id;
			socket.attributes.firstDate = data.firstDate;
			socket.attributes.secondDate = data.secondDate;
			socket.attributes.organization_id = data.organization_id;
			socket.organization_id = data.organization_id;
			if(!data.user_id)
				data.user_id = socket.user_id;
			reducer(actions.GET_SESSIONS(data), function(response){
				socket.emit(Types.GET_SESSIONS, response);
			});
		});
		socket.on("SET_FILTER", function(data){
			if(!socket.hasOwnProperty("attributes")){
				socket.attributes = {
					filters: [],
					user_id: socket.user_id || data.user_id
				};
			}
			socket.attributes.offset = data.offset;
			socket.attributes.order = data.order;
			socket.attributes.firstDate = data.firstDate;
			socket.attributes.secondDate = data.secondDate;
			if(!socket.attributes.user_id)
				socket.attributes.user_id = data.user_id;
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
						case 'faq':
						case 'partner':
						case 'sale':
							var filterKey = [];
							if(data.filter == "faq"){
								filterKey.push(socket.attributes.filters.indexOf("partner"));
								filterKey.push(socket.attributes.filters.indexOf("sale"));
							} else if (data.filter == "partner"){
								filterKey.push(socket.attributes.filters.indexOf("faq"));
								filterKey.push(socket.attributes.filters.indexOf("sale"));
							} else if (data.filter == "sale"){
								filterKey.push(socket.attributes.filters.indexOf("partner"));
								filterKey.push(socket.attributes.filters.indexOf("faq"));
							}
							break;
						case 'telegram':
						case 'widget':
							var filterKey = socket.attributes.filters.indexOf(data.filter == 'telegram' ? 'widget' : 'telegram');
							break;
						case 'today':
						case 'yesterday':
						case 'date':
							var filterKey = [];
							if(data.filter == "today"){
								filterKey.push(socket.attributes.filters.indexOf("yesterday"));
								filterKey.push(socket.attributes.filters.indexOf("date"));
							} else if (data.filter == "yesterday"){
								filterKey.push(socket.attributes.filters.indexOf("today"));
								filterKey.push(socket.attributes.filters.indexOf("date"));
							} else if (data.filter == "date"){
								filterKey.push(socket.attributes.filters.indexOf("yesterday"));
								filterKey.push(socket.attributes.filters.indexOf("today"));
							}
							break;
						case 'empty':
						case 'employed':
							var filterKey = socket.attributes.filters.indexOf(data.filter == 'empty' ? 'employed' : 'empty');
							break;
					}
					if(typeof filterKey != "object" && filterKey > -1){
						socket.attributes.filters.splice(filterKey, 1);
					} else if(typeof filterKey == "object" && filterKey.length > 0){
						filterKey.forEach(obj => {
							if(obj > -1){
								socket.attributes.filters.splice(obj, 1);
							}
						});
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
			if(!socket.organization_id)
				socket.organization_id = data.organization_id;
			if(!socket.attributes.user_id)
				socket.attributes.user_id = data.user_id;
			reducer(actions.BIND_SESSION(data), function(response){
				io.broadcastGetSessions(socket.organization_id);
				io.broadcastGetSessionInfo(data.session_id);
			});
		});
		socket.on(Types.UNBIND_SESSION, function(data){
			if(!socket.organization_id)
				socket.organization_id = data.organization_id;
			if(!socket.attributes.user_id)
				socket.attributes.user_id = data.user_id;
			reducer(actions.UNBIND_SESSION(data), function(response){
				io.broadcastGetSessions(socket.organization_id);
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
			socket.attributes.session_id = data;
			reducer(actions.GET_SESSION_INFO(data), function(response){
				socket.emit(Types.GET_SESSION_INFO, response);
			});
		});
		socket.on(Types.GET_SESSION_DIALOG, function(data){
			socket.switch = Types.GET_SESSION_DIALOG;
			socket.attributes.session_id = data;
			reducer(actions.GET_SESSION_DIALOG({session_id: data}), function(response){
				socket.emit(Types.GET_SESSION_DIALOG, response);
				socket.attributes.session_hash = (response ? response[0] ? response[0].session_hash : null : null);
			});
		});
		socket.on(Types.SET_ANSWER, function(data){
			reducer(actions.SET_ANSWER(data), function(response){
				io.broadcastGetSessionsDialog({session_id: data.session_id});
				io.broadcastGetSessionInfo(data.session_id);
				io.broadcastGetSessions(socket.organization_id);
				reducer(actions.GET_SESSION_INFO(data.session_id), function(session_info){
					session_info = session_info[0];
					if(session_info.session_telegram){
						var telegram_bot = session_info.session_partner ?
								telegram.partner :
								session_info.session_faq ?
									telegram.faq :
									session_info.session_sale ?
										telegram.sale :
										false;
						if(telegram_bot != false){
							var refactor_hash = data.hash.split("partner").join("").split("faq").join("").split("sale").join("");
							telegram_bot.sendMessage(refactor_hash, data.message);
						}
					}
				});
			});
			reducer(actions[Types.GET_SESSION_INFO](data.session_id), function(response){
				response = response[0] || {};
				if(response.session_error){
					reducer(actions[Types.REMOVE_ERROR_SESSION](response.session_hash), function(){
						io.broadcastGetSessionInfo(response.session_id);
						io.broadcastGetSessions(socket.organization_id);
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
					if(response && response[0]){
						socket.email = response[0].user_email;
					}
					io.broadcastGetUsers(socket.organization_id);
					io.broadcastGetSessions(socket.organization_id);
				});
			});
		});
		socket.on("WIDGET_GET_TOKEN", function(data){
			socket.type = "widget";
			socket.organization_id = data.organization_id;
			if(!socket.token){
				var random = [],
					number = Math.ceil(Math.random()*2);
				for(var i = 0; i < 10; i++){
					var symbol = (Math.random()*0xFFFFFF).toString(16)[0];
					random.push(Math.ceil(Math.random()*2) == number ? symbol.toLowerCase() : symbol.toUpperCase());
				}
				socket.token = random.join("");
			}
			reducer(actions.SET_SESSION({hash:data.subject + socket.token, type:"widget", subject: data.subject, organization_id: data.organization_id}), function(response){
				socket.emit("WIDGET_SET_TOKEN", socket.token);
				io.broadcastGetSessions(data.organization_id);
			});
		});
		socket.on(Types.GET_SESSION_ID, function(data){
			socket.token = data.token;
			socket.type = "widget";
			socket.switch = Types.GET_SESSION_DIALOG;
			socket.attributes.session_hash = data.token;
			socket.organization_id = data.organization_id;
			reducer(actions.GET_SESSION_ID(data.token), function(response){
				if(response.length == 0){
					var refactor_subject = data.token.indexOf("partner") == 0 ?
						"partner" :
						data.token.indexOf("faq") == 0 ?
							"faq" :
							data.token.indexOf("sale") == 0 ?
								"sale" :
								false;
					if(refactor_subject != false){
						reducer(actions.SET_SESSION({
							hash: data.token, 
							type: "widget", 
							subject: refactor_subject
						}), function(){
							reducer(actions.GET_SESSION_ID(data.token), function(responce){
								socket.emit(Types.GET_SESSION_ID, responce);
								socket.attributes.session_id = responce[0].session_id;
								reducer(actions.SET_ACTIVE({session_hash: data.token}), function(){
									io.broadcastGetSessions(data.organization_id);
									io.broadcastGetSessionInfo(socket.attributes.session_id);
								});
							});
						});
					}
				} else {
					socket.emit(Types.GET_SESSION_ID, response);
					socket.attributes.session_id = response[0].session_id;
					reducer(actions.SET_ACTIVE({session_hash: data.token}), function(){
						io.broadcastGetSessions(data.organization_id);
						io.broadcastGetSessionInfo(socket.attributes.session_id);
					});
				}
			});
		});
		socket.on("WIDGET_MESSAGE", function(data){
			reducer(actions.SET_QUESTION({message: data.message, hash: socket.token}), function(response){
				reducer(actions.GET_SESSION_INFO(socket.attributes.session_id), function(session_info){
					var bot_status = session_info[0].bot_work,
						ai = session_info[0].session_partner ?
							apiai.partner :
							session_info[0].session_faq ?
								apiai.faq :
								session_info[0].session_sale ?
									apiai.sale :
									apiai.partner;
					if(bot_status){
						var request = ai.textRequest(data.message, {sessionId: socket.token});
						request.on('response', function(response){
							reducer(actions.SET_ANSWER({hash: socket.token, message: response.result.fulfillment.speech}));
							if(response.result.action == 'input.unknown'){
								reducer(actions.SET_ERROR_SESSION(socket.token));
							} else if (response.result.action != 'input.unknown'){
								reducer(actions.REMOVE_ERROR_SESSION(socket.token));
							}
							io.broadcastGetSessionsDialog({session_hash: socket.token});
							io.broadcastGetSessions(data.organization_id);
							io.broadcastGetSessionInfo(socket.attributes.session_id);
						});
						setTimeout(function(){
							request.end();
						}, 7000);
					}
					socket.attributes.session_hash = socket.token;
					io.broadcastGetSessionInfo(socket.attributes.session_id);
					io.broadcastGetSessionsDialog({session_hash: socket.token});
					io.broadcastGetSessions(data.organization_id);
				});
			});
		});
		socket.on("WIDGET_CLIENT_INFO", function(data){
			reducer(actions[Types.UPDATE_CLIENT_INFORMATION](data.result), function(){
				io.broadcastGetClients(data.organization_id);
				io.broadcastGetSessionInfo(socket.attributes.session_id);
				reducer(actions[Types.GET_CLIENT_ID](data.result.session_id), function(responce){
					io.broadcastGetClient(responce[0].client_id);
				});
			});
		});
		socket.on("WIDGET_SET_CLIENT", function(data){
			data.client_ip = socket.handshake.address;
			data.client_url = socket.handshake.headers.origin;
			var client_ua = ua(socket.handshake.headers["user-agent"]);
			data.client_ua = socket.handshake.headers["user-agent"];
			data.client_browser_name = client_ua.browser.name;
			data.client_browser_version = client_ua.browser.version;
			data.client_engine_name = client_ua.engine.name;
			data.client_engine_version = client_ua.engine.version;
			data.client_os_name = client_ua.os.name;
			data.client_os_version = client_ua.os.version;
			data.client_device_vendor = client_ua.device.vendor;
			data.client_device_model = client_ua.device.model;
			data.client_device_type = client_ua.device.type;
			reducer(actions[Types.SET_CLIENT](data), function(){
				io.broadcastGetClients(data.organization_id);
				io.broadcastGetSessions(data.organization_id);
				io.broadcastGetSessionInfo(socket.attributes.session_id);
			});
		});
		socket.on(Types.REMOVE_ERROR_SESSION, function(data){
			reducer(actions[Types.REMOVE_ERROR_SESSION](data.session_hash), function(){
				io.broadcastGetSessions(socket.organization_id);
				io.broadcastGetSessionInfo(data.session_id);
			});
		});
		socket.on(Types.SEND_EMAIL, function(data){
			reducer(actions[Types.SEND_EMAIL](data), function(response){
				socket.emit(Types.SEND_EMAIL, response);
			});
		});
		socket.on(Types.GET_DISPATCHES, function(data){
			socket.switch = Types.GET_DISPATCHES;
			reducer(actions[Types.GET_DISPATCHES](data), function(response){
				socket.emit(Types.GET_DISPATCHES, response);
			});
		});
		socket.on(Types.DELETE_DISPATCH, function(data){
			reducer(actions[Types.DELETE_DISPATCH](data.dispatch_id), function(response){
				io.broadcastGetDispatches(data.organization_id);
			});
		});
		socket.on(Types.NEW_DISPATCH, function(data){
			reducer(actions[Types.GET_ALL_SESSIONS](data.organization_id), function(responce){
				for(var i = 0; i < responce.length; i++){
					var session = responce[i];
					if((session.session_partner && data.dispatch_partner) || (session.session_faq && data.dispatch_faq) || (session.session_sale && data.dispatch_sale)){
						if(data.dispatch_telegram && session.session_telegram){
							reducer(actions[Types.SET_ANSWER]({
								hash: session.session_hash, 
								session_id: session.session_id, 
								message: data.dispatch_message
							}), (function(obj, response){
								if(response){
									var telegram_bot = obj.session_partner ?
											telegram.partner :
												obj.session_faq ?
													telegram.faq :
													obj.session_sale ?
														telegram.sale :
														false;
									if(telegram_bot != false){
										var refactor_hash = obj.hash.split("partner").join("").split("faq").join("").split("sale").join("");
										telegram_bot.sendMessage(refactor_hash, obj.message);
										io.broadcastGetSessionsDialog({session_id: obj.id});
										io.broadcastGetSessionInfo(obj.id);
										io.broadcastGetSessions(socket.organization_id);
									}
								}
							}).bind(this, {
								hash: session.session_hash, 
								message: data.dispatch_message, 
								id: session.session_id,
								session_partner: session.session_partner,
								session_faq: session.session_faq,
								session_sale: session.session_sale
							}));
						} else if (data.dispatch_widget && session.session_widget) {
							reducer(actions[Types.SET_ANSWER]({
								hash: session.session_hash, 
								session_id: session.session_id, 
								message: data.dispatch_message
							}), (function(obj, response){
								if(response){
									io.broadcastGetSessionsDialog({session_id: obj.id});
									io.broadcastGetSessionInfo(obj.id);
									io.broadcastGetSessions(socket.organization_id);
								}
							}).bind(this, {
								hash: session.session_hash, 
								message: data.dispatch_message, 
								id: session.session_id
							}));
						}
					}
				}
				reducer(actions[Types.NEW_DISPATCH](data), function(response){
					io.broadcastGetDispatches(data.organization_id);
				});
			});
		});
		socket.on(Types.GET_CLIENTS, function(data){
			socket.switch = Types.GET_CLIENTS;
			reducer(actions[Types.GET_CLIENTS](data), function(response){
				socket.emit(Types.GET_CLIENTS, response);
			});
		});
		socket.on(Types.GET_CLIENT, function(data){
			socket.switch = Types.GET_CLIENT;
			socket.client_id = data;
			reducer(actions[Types.GET_CLIENT](data), function(response){
				socket.emit(Types.GET_CLIENT, response);
			});
		});
		socket.on(Types.UPDATE_CLIENT_INFORMATION, function(data){
			reducer(actions[Types.UPDATE_CLIENT_INFORMATION](data), function(responce){
				reducer(actions[Types.GET_CLIENT](data.client_id), function(response){
					socket.emit(Types.GET_CLIENT, response);
					io.broadcastGetClients();
					io.broadcastGetClient(data.client_id);
					io.broadcastGetSessionInfo(data.session_id);
				});
			});
		});
		socket.on(Types.GET_ORGANIZATIONS, function(data){
			socket.switch = Types.GET_ORGANIZATIONS;
			reducer(actions[Types.GET_ORGANIZATIONS](data), function(response){
				socket.emit(Types.GET_ORGANIZATIONS, response);
			});
		});
		socket.on(Types.GET_ORGANIZATION, function(data){
			socket.switch = Types.GET_ORGANIZATION;
			socket.organization_id = data;
			reducer(actions[Types.GET_ORGANIZATION](data), function(response){
				socket.emit(Types.GET_ORGANIZATION, response);
			});
		});
		socket.on(Types.UPDATE_ORGANIZATION_INFORMATION, function(data){
			reducer(actions[Types.UPDATE_ORGANIZATION_INFORMATION](data), function(response){
				io.broadcastGetOrganization(data.organization_id);
				io.broadcastGetOrganizations();
			});
		});
		socket.on(Types.CREATE_ORGANIZATION, function(data){
			reducer(actions[Types.CREATE_ORGANIZATION](data), function(response){
				io.broadcastGetOrganizations();
			});
		});
		socket.on(Types.GET_USER_ORGANIZATION, function(data){
			reducer(actions[Types.GET_USER_ORGANIZATION](data), function(response){
				socket.emit(Types.GET_USER_ORGANIZATION, response[0]);
			});
		});
	});
}