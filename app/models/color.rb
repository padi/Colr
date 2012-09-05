class Color
  PROPERTIES = [:timestamp, :hex, :id, :tags]
  PROPERTIES.each { |prop|
    attr_accessor prop
  }

  def initialize hash={}
    hash.each { |key, value|
      if PROPERTIES.member? key.to_sym
        self.send key.to_s + "=", value
      end
    }
  end

  # Custom getter/setter methods for tags
  def tags
    @tags ||= []
  end

  def tags= tags
    if tags.first.is_a? Hash
      tags = tags.collect { |tag| Tag.new tag }
    end

    tags.each { |tag|
      if not tag.is_a? Tag
        raise "Wrong class for attempted tag #{tag.inspect}"
      end
    }

    @tags = tags
  end

  def self.find hex, &block
    BW::HTTP.get "http://www.colr.org/json/color/#{hex || ""}" do |response|
      result_data = BW::JSON.parse(response.body.to_str)
      color_data = result_data["colors"][0]

      ## Colr will return a color with id == -1 if no color was found
      color = Color.new color_data
      if color.id.to_i == -1
        block.call nil
      else
        block.call color
      end
    end
  end
end
