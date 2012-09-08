module Righthand
  module Monkeypatches
    module BlogArticle
    end
  end
end

module ::Middleman
  module Blog
    module BlogArticle
      def author
        a = data.author || "negonicrac"
        @app.data.authors[a]
      end

      def to_json
        serializable_hash.to_json
      end

      def published
        !!data.published
      end

      def comments
        !!data.comments
      end

      def serializable_hash(options = nil)
        {
          id: url.gsub(/.html$/,""),
          url: url.gsub(/.html$/,".json"),
          slug: slug,
          mime_type: mime_type,
          title: title,
          display_title: data["eng_title"] || title,
          date: date,
          published: data.published,
          comments: data.comments,
          tags: tags,
          summary: summary,
          body: body,
          author: {
            name: author.name,
            url: author.url,
            email: author.email
          }
        }
      end
    end
  end
end
