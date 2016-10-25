require "pry"
require "refile/mini_magick"

RSpec.describe Refile::MiniMagick do
  let(:portrait) { Tempfile.new(["portrait", ".jpg"]) }
  let(:landscape) { Tempfile.new(["landscape", ".jpg"]) }

  def fixture_path(name)
    File.expand_path("./fixtures/#{name}", File.dirname(__FILE__))
  end

  before do
    FileUtils.cp(fixture_path("portrait.jpg"), portrait.path)
    FileUtils.cp(fixture_path("landscape.jpg"), landscape.path)
  end

  describe "#convert" do
    it "changes the image format" do
      file = Refile::MiniMagick.new(:convert).call(portrait, "png")
      expect(::MiniMagick::Image.new(file.path).identify).to match(/PNG/)
    end

    it "yields the command object" do
      expect { |b| Refile::MiniMagick.new(:convert).call(portrait, "png", &b) }
        .to yield_with_args(MiniMagick::Tool)
    end
  end

  describe "#limit" do
    it "resizes the image up to a given limit" do
      file = Refile::MiniMagick.new(:limit).call(portrait, "400", "400")
      result = ::MiniMagick::Image.new(file.path)
      expect(result.width).to eq(300)
      expect(result.height).to eq(400)
    end

    it "yields the command object" do
      expect { |b| Refile::MiniMagick.new(:limit).call(portrait, "400", "400", &b) }
        .to yield_with_args(MiniMagick::Tool)
    end
  end

  describe "#fit" do
    it "resizes the image to fit given dimensions" do
      file = Refile::MiniMagick.new(:fit).call(portrait, "400", "400")
      result = ::MiniMagick::Image.new(file.path)
      expect(result.width).to eq(300)
      expect(result.height).to eq(400)
    end

    it "yields the command object" do
      expect { |b| Refile::MiniMagick.new(:fit).call(portrait, "400", "400", &b) }
        .to yield_with_args(MiniMagick::Tool)
    end
  end

  describe "#fill" do
    it "resizes and crops the image to fill out the given dimensions" do
      file = Refile::MiniMagick.new(:fill).call(portrait, "400", "400")
      result = ::MiniMagick::Image.new(file.path)
      expect(result.width).to eq(400)
      expect(result.height).to eq(400)
    end

    it "yields the command object" do
      expect { |b| Refile::MiniMagick.new(:fill).call(portrait, "400", "400", &b) }
        .to yield_with_args(MiniMagick::Tool)
    end
  end

  describe "#pad" do
    it "resizes and fills out the remaining space to fill out the given dimensions" do
      file = Refile::MiniMagick.new(:pad).call(portrait, "400", "400", "red")
      result = ::MiniMagick::Image.new(file.path)
      expect(result.width).to eq(400)
      expect(result.height).to eq(400)
    end

    it "yields the command object" do
      expect { |b| Refile::MiniMagick.new(:pad).call(portrait, "400", "400", &b) }
        .to yield_with_args(MiniMagick::Tool)
    end
  end
end
