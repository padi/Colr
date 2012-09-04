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
    BW::HTTP.get "http://www.color.org/json/color/#{hex}" do |response|
      p response.body.to_str
      # for now, pass nil
      block.call nil
    end
  end
end
