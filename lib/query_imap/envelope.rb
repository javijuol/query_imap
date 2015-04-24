class QueryIMAP
	module Envelope
		attr_accessor :message_id, :date, :subject, :from, :to, :cc, :bcc, :reply_to, :in_reply_to

		def envelope=(envelope)
			@message_id   = envelope.message_id[/<([^>]*)/,1]
			@date         = DateTime.parse(envelope.date)
			@subject      = envelope.subject
			@from         = Address.new(envelope.from.first)
			@to           = Address.new(envelope.to)
			@cc           = Address.new(envelope.cc)
			@bcc          = Address.new(envelope.bcc)
			@reply_to     = Address.new(envelope.reply_to)
			@in_reply_to  = Address.new(envelope.in_reply_to)
		end

		class Address
			attr_accessor :address, :display_name

			def initialize(address)
				if address.is_a?(Net::IMAP::Address)
					@address = "#{address.mailbox}@#{address.host}"
					@display_name = address.name
				elsif address.is_a?(String)
					_,@display_name,@address = address.scan(/((.*)\s*<(.+)>|(.{0})(.+))/)[0].compact
				else
					raise InvalidAddress
				end
			end

			def to_s
				"#{@display_name} <#{@address}>"
			end

			private

			class InvalidAddress < StandardError; end
		end

	end
end