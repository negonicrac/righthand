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
        when 11..13 then "#{num}th"
        else
          case num % 10
          when 1 then "#{num}st"
          when 2 then "#{num}nd"
          when 3 then "#{num}rd"
          else "#{num}th"
          end
        end
      end
    end
  end
end
