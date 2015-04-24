require 'query_imap/envelope'

class QueryIMAP
	class Message
		include Envelope

		attr_accessor :mailbox, :sequence_number, :uid, :body_html, :body_plain, :flags, :size

		def initialize(mailbox)
			@mailbox = mailbox.to_s
		end

	end
end