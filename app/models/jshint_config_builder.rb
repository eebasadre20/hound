class JshintConfigBuilder < ConfigBuilder
  pattr_initialize :hound_config

  def self.for(hound_config)
    new(hound_config).config
  end

  def config
    config_class.new(load_content)
  end

  private

  def config_class
    Config::Jshint
  end

  def linter_name
    "jshint"
  end

  def load_content
    if file_path
      if url?
        fetch_url
      else
        commit.file_content(file_path)
      end
    else
      default_content
    end
  end

  def fetch_url
    response = Faraday.new.get(file_path)

    if response.success?
      response.body
    else
      raise_parse_error("#{response.status} #{response.body}")
    end
  end

  def url?
    URI::regexp(%w(http https)).match(file_path)
  end

  def file_path
    linter_config && linter_config["config_file"]
  end

  def linter_config
    hound_config.content.slice(linter_name).values.first
  end

  def commit
    hound_config.commit
  end
end
