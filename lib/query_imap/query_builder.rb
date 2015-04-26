require 'query_imap/message'

class QueryIMAP
	module QueryBuilder

		MESSAGE     = 'RFC822'
		FLAGS       = 'FLAGS'
		UID         = 'UID'
		SIZE        = 'RFC822.SIZE'
		ENVELOPE    = 'ENVELOPE'
		DATE        = 'INTERNALDATE BODY[HEADER.FIELDS (DATE)]'
		MESSAGE_ID  = 'BODY[HEADER.FIELDS (MESSAGE-ID)]'
		SUBJECT     = 'BODY[HEADER.FIELDS (SUBJECT)]'
		FROM        = 'BODY[HEADER.FIELDS (FROM)]'

		attr_accessor :client, :with

		def select(*opts)
			@with = opts
			self
		end

		def all
			self.where
		end

		def where(query='ALL')
			found = @client.search(query.split)
			found = _fetch(found) unless found.empty?
			found.map{|f| _map_fetch(f)}
		end

		def [](uid)
			_map_fetch(_uid_fetch(uid).first)
		end

		private

		def _with
			"(#{@with.join(' ')})"
		end

		def _uid_fetch(uid)
			@client.uid_fetch([uid], _with)
		end

		def _fetch(ids)
			@client.fetch(ids, _with)
		end

		def _map_fetch(fetched)
			message = Message.new(self)
			@with.each do |with|
				case with
					when MESSAGE
						# message = fetched.attr[with] #TODO
					when FLAGS
						message.flags = fetched.attr[with]
					when UID
						message.uid = fetched.attr[with]
					when ENVELOPE
						message.envelope = fetched.attr[with]['ENVELOPE']
					when MESSAGE_ID
						message.message_id = fetched.attr[with][/.*<([^>]*)/,1]
					when SIZE
						message.size = fetched.attr[with]
					when DATE
						message.date = DateTime.parse(fetched.attr['BODY[HEADER.FIELDS (DATE)]'].nil? ? fetched.attr['BODY[HEADER.FIELDS (DATE)]'].gsub(/^Date:\s/i,'').chomp('') : fetched.attr['INTERNALDATE'])
					when SUBJECT
						message.subject = fetched.attr[with].gsub(/^Subject:\s/i,'').chomp('')
					when FROM
						message.from = Message::Address.new(fetched.attr[with])
					else
				end
			end
			message
		end

	end
end