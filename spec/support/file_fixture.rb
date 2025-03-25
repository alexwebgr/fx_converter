# frozen_string_literal: true

def file_fixture(filename)
  file_path = File.join("spec", "fixtures", "files", filename)
  File.read(file_path)
end
