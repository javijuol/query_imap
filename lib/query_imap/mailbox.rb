require 'query_imap/query_builder'

class QueryIMAP
	class Mailbox
	include QueryBuilder

		FOLDER_INBOX = 'INBOX'

		attr_accessor :client, :namespace, :folder, :delim, :examine, :flags
		private :examine

		def has_mailbox?(mailbox)
			self.list.include? mailbox
		end

		def initialize(client,mailbox='')
			@client = client
			_delim
			@namespace,_,@folder = mailbox.rpartition(@delim)
		end

		def list
			_list.map(&:name)
		end

		def open(examine=false)
			@examine = examine
			raise MailboxNotFound unless exists?
			@client.send((examine ? 'examine' : 'select'), self.to_s)
			untagged_response = @client.responses
			@flags = untagged_response['FLAGS'][0]
			self
		end

		def silently_open
			open true
		end

		def create
			begin
				@client.create self.to_s
			rescue Net::IMAP::NoResponseError
				raise MailboxCreationNotAllowed
			end
		end

		def delete
			begin
				@client.delete self.to_s
			rescue Net::IMAP::NoResponseError
				raise MailboxDeletionNotAllowed
			end
		end

		def examine?
			@examine
		end

		def exists?
			list.include? self.to_s
		end

		def to_s
			@namespace.empty? ? @folder : "#{@namespace}#{@delim}#{@folder}"
		end

		%w(sent trash archive delete spam).each do |smart_mailbox|
			method = "#{smart_mailbox}_folder"
			define_method(method) do
				return list.to_a.select{|f| _smart_translation(smart_mailbox).inject(false){|t,s| t | (f.downcase.include? s)}}.map{|f| self.new(f)}
			end
		end

		def root_mailbox_path
			_root_mailbox_path
		end

		def count
			_status('MESSAGES')
		end

		def recent
			_status('RECENT')
		end

		def unseen
			_status('UNSEEN')
		end

		def uid_validity
			_status('UIDVALIDITY')
		end

		def uid_next
			_status('UIDNEXT')
		end

		private

		def _delim
			@delim ||= _list.first.delim
		end

		def _list
			@client.list '','*'
		end

		def _status(stat)
			@client.status(self.to_s,[stat])
		end

		def _smart_translation(folder)
			case folder
				when 'sent'
					%w(sent enviado)
				when 'trash'
					%w(trash papelera)
				when 'trash'
					%w(trash papelera)
				when 'archive'
					%w(archive archivado)
				when 'delete'
					%w(delete borrado)
				when 'spam'
					%w(spam deseado)
				else
					%w()
			end
		end

		def _root_mailbox_path
			@root_mailbox_path ||= _has_inbox_as_root? ? "#{FOLDER_INBOX}#{@delim}" : ''
		end

		def _has_inbox_as_root?
			checker = self.class.new(@client,'query_mailbox_test')
			checker.create
			checker.delete
			false
		rescue MailboxCreationNotAllowed,  MailboxDeletionNotAllowed
			true
		end

		class MailboxNotFound < StandardError; end
		class MailboxCreationNotAllowed < StandardError; end
		class MailboxDeletionNotAllowed < StandardError; end
	end
end