require 'query_imap/envelope'

class QueryIMAP
	class Message
		include Envelope

		attr_accessor :mailbox, :sequence_number, :uid, :body_html, :body_plain, :flags, :size

		def initialize(mailbox)
			@mailbox = mailbox.to_s
    end

    def fetch_message(message)

    end

    def fetch_message_id(message_id)
      message_id[/.*<([^>]*)/,1]
    end

    def fetch_date(date)
      date.gsub(/^Date:\s/i,'').chomp('')
    end

    def fetch_subject(subject)
      subject.gsub(/^Subject:\s/i,'').chomp('')
    end

    def fetch_address(address)
      Message::Address.new(address)
    end

	end
end