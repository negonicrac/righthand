require 'redcarpet'
require 'oembed'

module Righthand
  OEmbed::Providers.register_all

  class HTML < ::Redcarpet::Render::HTML
    include Redcarpet::Render::SmartyPants

    attr_accessor :middleman_app

    def parse_media_title(title)
      unless title.nil?
        matches = title.match(/^(\w+)?\|([\w\s\d]+)$/)
        if matches
          { title: matches[1],
            align: (matches[2] || 'original').to_sym }
        end
      end
    end

    def image(link, title, alt_text)
      align = nil

      unless (parse = parse_media_title(title)).nil?
        title = parse[:title]
        align = parse[:align]
      end

      case align
      when :center
        middleman_app.content_tag(:div, class: 'center-text') do
          middleman_app.image_tag(link, title: title, alt: alt_text)
        end
      else
        middleman_app.image_tag(link, title: title, alt: alt_text)
      end
    end

    def link(link, title, content)
      align = nil

      unless (parse = parse_media_title(title)).nil?
        title = parse[:title]
        align = parse[:align]
      end

      case align
      when :center
        middleman_app.content_tag(:div, class: 'center-text') do
          middleman_app.link_to(content, link, title: title)
        end
      else
        middleman_app.link_to(content, link, title: title)
      end
    end

    def preprocess(full_document)
      full_document = full_document.gsub(/\[youtube ([\w\s\d]+)\]/) do
        link = "http://youtu.be/#{Regexp.last_match(1)}"

        middleman_app.content_tag(:div) do
          [middleman_app.content_tag(:div, class: 'fluid-video') do
             OEmbed::Providers.get(link).html
           end,
           middleman_app.content_tag(:div) do
             middleman_app.link_to(link, link)
           end].join
        end
      end

      full_document
    end
  end
end
