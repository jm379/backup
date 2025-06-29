module Backup
  class Adapters
    class Backup
      def call
        raise NotImplementedError
      end

      def hash
        raise NotImplementedError
      end
    end
  end
end
