class QueryIMAP
	module Login
		class AbstractLogin
		attr_accessor :client, :user

		AUTH_CAPABILITY = 'AUTH=PLAIN'

		def initialize(client)
			@client = client
			raise UnsupportedCapability unless self.capability? self.class::AUTH_CAPABILITY
		end

		def capability?(capability)
			self.capabilities.include?(capability)
		end

		protected

		def capabilities
			@client.capability
		end

		class UnsupportedCapability < StandardError; end
		end

		class IMAP < AbstractLogin
			AUTH_CAPABILITY = 'AUTH=LOGIN'

			attr_accessor :pass
			private :pass

			def initialize(client, user, pass)
				super(client)
				@user = user
				@pass = pass
				@client.login(@user, @pass)
			end
		end

		class XOAuth2 < AbstractLogin

			AUTH_CAPABILITY = 'AUTH=XOAUTH2'
			AUTH_METHOD = 'XOAUTH2'
			OAUTH_URL = nil

			attr_accessor :refresh_token, :key, :secret
			private :secret

			def initialize(client, user, token, key, secret)
				super(client)
				raise UndefinedOAuthURL if OAUTH_URL.nil?
				@user = user
				@refresh_token = token
				@key = key
				@secret = secret
				Net::IMAP.add_authenticator(AUTH_METHOD, self.class)
				@client.authenticate(AUTH_METHOD, @user, access_token)
			end

			def process(s)
				"user=#{@user}\x01auth=Bearer #{access_token}\x01\x01"
			end

			private

			def access_token
				uri = URI(OAUTH_URL)
				res = Net::HTTP.post_form(uri,
																	'client_id' => key,
																	'client_secret' => @secret,
																	'grant_type' => 'refresh_token',
																	'refresh_token' => @refresh_token)
				raise 'Invalid credentials' unless res.code == '200'
				JSON.parse(res.body)['access_token']
			end

			class UndefinedOAuthURL < StandardError; end
		end

		class Gmail < XOAuth2
			OAUTH_URL = 'https://www.googleapis.com/oauth2/v3/token'
		end

		class Microsoft < XOAuth2
			OAUTH_URL = 'https://login.live.com/oauth20_token.srf'
		end
	end

end