module.exports = function(telegram, apiai, reducer, actions, io, subject){
	telegram.on("message", function(message){
		var connection = telegram.connections.find(function(connection){
			return connection.hash == message.chat.id;
		});
		if(!connection){
			connection = telegram.connections[telegram.connections.push({hash: subject + message.chat.id, bot: true, error: false}) - 1];
			reducer(actions.SET_SESSION({hash: subject + message.chat.id, type:"telegram", subject: subject}));
			reducer(actions.GET_SESSION_ID(subject + message.chat.id), function(response){
				connection.session_id = response[0].session_id;
				reducer(actions.SET_CLIENT({
					client_name: message.from.first_name + " " + message.from.last_name,
					client_username: message.from.username,
					session_id: connection.session_id
				}), function(responce){
					io.broadcastGetClients();
					io.broadcastGetSessions();
					io.broadcastGetSessionInfo(connection.session_id);
				});
			});
		}
		if(!connection.active){
			reducer(actions.SET_ACTIVE({session_hash: subject + message.chat.id}), function(){
				io.broadcastGetSessions();
				io.broadcastGetSessionInfo(connection.session_id);
				message.active = true;
			});
		}
		if(connection.timeout_id){
			clearTimeout(connection.timeout_id);
		}
		connection.timeout_id = setTimeout(function(){
			reducer(actions.SET_INACTIVE({session_hash: subject + message.chat.id}), function(){
				io.broadcastGetSessions();
				io.broadcastGetSessionInfo(connection.session_id);
				message.active = false;
			});
		}, 600000);
		reducer(actions.SET_QUESTION({
			message: message.text,
			hash: subject + message.chat.id
		}));
		io.broadcastGetSessionsDialog({session_hash: subject + message.chat.id});
		io.broadcastGetSessions();
		var request = apiai.textRequest(message.text, {sessionId: subject + message.chat.id});
		request.on('response', function(response){
			reducer(actions.GET_BOT_STATUS({session_hash: subject + message.chat.id}), function(data){
				data = data[0];
				if(data.bot_work){
					reducer(actions.SET_ANSWER({hash: subject + message.chat.id, message: response.result.fulfillment.speech}));
					reducer(actions.GET_SESSION_INFO(connection.session_id), function(session){
						session = session[0] || {};
						if(session.session_error && response.result.action != 'input.unknown'){
							reducer(actions.REMOVE_ERROR_SESSION(session.session_hash), function(){
								io.broadcastGetSessions();
								io.broadcastGetSessionInfo(session.session_id);
							});
						} else if(!session.session_error && response.result.action == 'input.unknown'){
							reducer(actions.SET_ERROR_SESSION(session.session_hash), function(){
								io.broadcastGetSessions();
								io.broadcastGetSessionInfo(session.session_id);
							});
						}
					});
					if(response.result.fulfillment.speech){
						telegram.sendMessage(message.chat.id, response.result.fulfillment.speech);
					}
					io.broadcastGetSessionsDialog({session_hash: subject + message.chat.id});
					io.broadcastGetSessionInfo(connection.session_id);
					io.broadcastGetSessions();
				}
			});
		});
		setTimeout(function(){
			request.end();
		}, 7000);
	});
}