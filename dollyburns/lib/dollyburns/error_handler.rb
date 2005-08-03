# DollyBurns' error handler definitions

require 'net/smtp'

module DollyBurns
   def DollyBurns.flush_messages(smtp, fromAddress, pendingHash)
      pendingHash.each_pair do |address, messages|
         smtp.send_message messages.join("\n--\n"), fromAddress, address
      end
   end

   # Sends messages by email
   class ErrorHandler
      # autoFlush sends messages automatically, instead of queuing them for
      # later, batch sending
      def initialize(fromEmail, defaultEmail, emailServer, emailPort = 25, autoFlush = false)
         @fromEmail    = fromEmail
         @defaultEmail = defaultEmail
         @smtp         = Net::SMTP.start(emailServer, emailPort)
         @autoFlush    = autoFlush
         @pending      = {}

         ObjectSpace.define_finalizer(self, ErrorHandler.create_finalizer(@smtp, @fromEmail, @pending))
      end

      # Queues a message for sending
      def message(text, email = @defaultEmail)
         @pending[email] ||= []
         @pending[email] << text
         flush if @autoFlush
      end

      # Flush pending messages
      def flush
         DollyBurns.flush_messages(@smtp, @fromEmail, @pending)
         @pending = {}
      end

      # Object "destructor", to flush pending messages
      def ErrorHandler.create_finalizer(smtp, fromAddress, pendingHash)
         proc {|id| DollyBurns.flush_messages(smtp, fromAddress, pendingHash) }
      end
   end
end
