module Righthand
  module Helpers
    module AuthorHelpers
      def author_name(name)
        author(name).name
      end

      def author_url(name)
        author(name).url
      end

      private

      def author(name)
        name ||= 'negonicrac'
        data.authors[name.to_sym]
      end
    end
  end
end
