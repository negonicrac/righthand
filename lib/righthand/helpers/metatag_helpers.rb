module Righthand
  module Helpers
    module MetatagHelpers
      def page_title
        [yield_content(:title), data.site.name].compact.delete_if { |x| x.blank? }.join(" | ")
      end

      def page_description
        [yield_content(:meta_description), data.site.description].compact.delete_if { |x| x.blank? }.first
      end

      def page_keywords
        [yield_content(:meta_keywords), data.site.keywords].compact.delete_if { |x| x.blank? }.first
      end

      def page_feed_url
        data.site.feed_url
      end
    end
  end
end
