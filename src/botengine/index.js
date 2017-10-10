module.exports = function(request, env){
	return {
		requestConstructor: function(message, session_hash, env, request){
			this.request = request;
			this.env = env;
			this.message = message;
			this.session_hash = session_hash;
			this.clientToken = this.clientToken;
			this.callback = function(callback){
				this.callback = callback;
			};
			this.end = function(){
				request({
					url: "https://api.botengine.ai/query",
					headers: {
						authorization: "Bearer " + this.env.token,
						'content-type': "application/json;charset=UTF-8"
					},
					body: JSON.stringify({
						query: this.message,
						sessionId: this.session_hash 
					}),
					method: "POST"
				}, this.callback || false);
			};
			return this;
		},
		env: env,
		query: request,
		request: function(message, session_hash){
			return new this.requestConstructor(message, session_hash, this.env, this.query);
		}
	}
}