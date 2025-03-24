# frozen_string_literal: true

require 'yaml'
require 'active_support/encrypted_file'
require 'securerandom'
require 'fileutils'
require 'tempfile'

class CredentialsManager
  attr_reader :key_path
  attr_reader :credentials_path

  def initialize(options = {})
    @key_path = options[:key_path] || 'config/master.key'
    @credentials_path = options[:credentials_path] || 'config/credentials.yml.enc'
  end

  def generate
    return "Key already exists at #{key_path}. Aborting to prevent overwriting." if File.exist?(key_path)
    return "Credentials file already exists at #{credentials_path}. Aborting to prevent overwriting." if File.exist?(credentials_path)

    FileUtils.mkdir_p(File.dirname(@key_path))
    FileUtils.mkdir_p(File.dirname(credentials_path))

    default_content = {
      "secret_key_base" => SecureRandom.hex(64)
    }

    File.open(key_path, 'w', 0600) { |f| f.write(SecureRandom.hex(16)) }
    encrypted_file.write(YAML.dump(default_content))
    File.open(".gitignore", "a") do |f|
      f.puts "config/master.key"
    end

    [
      "Created encryption key at: #{key_path}",
      "Created encrypted credentials file at: #{credentials_path}",
      "Added master.key to .gitignore",
      ""
    ].join("\n")
  end

  def edit
    return "key or credentials missing" unless File.exist?(key_path) && File.exist?(credentials_path)

    temp_file = Tempfile.new("credentials.yml")
    temp_file.write(encrypted_file.read)
    temp_file.close

    system("#{ENV['EDITOR']} #{temp_file.path}")

    new_content = File.read(temp_file.path)

    YAML.safe_load(new_content)
    encrypted_file.write(new_content)
    temp_file.unlink

    [
      "Credentials updated successfully!",
      ""
    ].join("\n")
  end

  def read
    YAML.safe_load(encrypted_file.read)
  end

  private

  def encrypted_file
    ActiveSupport::EncryptedFile.new(
      content_path: credentials_path,
      env_key: "",
      key_path: key_path,
      raise_if_missing_key: true
    )
  end
end
