module Righthand
  module Helpers
    module DateHelpers
      def month_name(month_number)
        month_number = month_number.to_i
        Date::MONTHNAMES[month_number]
      end

      def ordinal(num)
        num = num.to_i
        case num % 100
          when 11..13; "#{num}th"
        else
          case num % 10
            when 1; "#{num}st"
            when 2; "#{num}nd"
            when 3; "#{num}rd"
            else    "#{num}th"
          end
        end
      end
    end
  end
end
