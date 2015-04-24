class QueryIMAP

	FETCH_MACROS              = 'RFC822 FLAGS UID'
	FETCH_MACROS_BODY         = 'RFC822'
	FETCH_MACROS_FAST         = 'ENVELOPE FLAGS UID'
	FETCH_MACROS_MESSAGE_ID   = 'BODY[HEADER.FIELDS (MESSAGE-ID)]'

	attr_accessor :client, :host, :login, :logged_in
	private :logged_in

	def initialize(hostname, port=993, ssl=true)
		@host ||= hostname
		@client ||= Net::IMAP.new(@host, port, ssl, nil, false)
		@logged_in = false
	end

	def capability?(capability)
		capabilities.include?(capability)
	end

	def login(username, credentials)
		credentials.delete_if { |k, v| v.nil? }
		case
			when credentials.has_key?(:refresh_token) && credentials.has_key?(:consumer_key) && credentials.has_key?(:consumer_secret)
				if @host =~ /google|gmail/
					Login::Gmail.new(@client, username, credentials[:refresh_token], credentials[:consumer_key], credentials[:consumer_secret])
				elsif @host =~ /outlook|hotmail/
					Login::Microsoft.new(@client, username, credentials[:refresh_token], credentials[:consumer_key], credentials[:consumer_secret])
				else
					raise WrongParamsLogin
				end
			when credentials.has_key?(:password)
				Login::IMAP.new(@client, username,credentials[:password])
			else
				raise WrongParamsLogin
		end
		@logged_in = true
		self
	end

	def logout
		@client.logout if self.logged_in?
	end

	def logged_in?
		@logged_in
	end

	def connected?
		!@client.disconnected?
	end

	def disconnect
		@client.disconnect if self.connected?
		@host = nil
		@client = nil
	end


	def mailboxes
		Mailbox.new(@client).list
	end

	def mailbox(mailbox)
		Mailbox.new(@client, mailbox)
	end

	private

	def capabilities
		@client.capability
	end

	class WrongParamsLogin < StandardError; end

end

require 'query_imap/version'
require 'query_imap/login'
require 'query_imap/mailbox'
require 'net/imap'
