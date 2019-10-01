require "refile"
require "refile/mini_magick/version"
require "image_processing/mini_magick"

module Refile
  # Processes images via MiniMagick, resizing cropping and padding them.
  class MiniMagick
    # @param [Symbol] method        The method to invoke on {#call}
    def initialize(method)
      @method = method
    end

    # Changes the image encoding format to the given format
    #
    # @see http://www.imagemagick.org/script/command-line-options.php#format
    # @param [ImageProcesing::Pipeline] pipeline   processing pipeline to call
    # @param [String] format                       the format to convert to
    # @return [Tempfile]
    def convert(pipeline, format)
      pipeline.convert!(format)
    end

    # Resize the image to fit within the specified dimensions while retaining
    # the original aspect ratio. Will only resize the image if it is larger
    # than the specified dimensions. The resulting image may be shorter or
    # narrower than specified in either dimension but will not be larger than
    # the specified values.
    #
    # @param [ImageProcesing::Pipeline] pipeline   processing pipeline to call
    # @param [#to_s] width                         the maximum width
    # @param [#to_s] height                        the maximum height
    # @yield [MiniMagick::Tool::Convert]
    # @return [Tempfile]
    def limit(pipeline, width, height)
      pipeline.resize_to_limit!(width || "!", height || "!")
    end

    # Resize the image to fit within the specified dimensions while retaining
    # the original aspect ratio. The image may be shorter or narrower than
    # specified in the smaller dimension but will not be larger than the
    # specified values.
    #
    # @param [ImageProcesing::Pipeline] pipeline   processing pipeline to call
    # @param [#to_s] width                         the width to fit into
    # @param [#to_s] height                        the height to fit into
    # @return [Tempfile]
    def fit(pipeline, width, height)
      pipeline.resize_to_fit!(width, height)
    end

    # Resize the image so that it is at least as large in both dimensions as
    # specified, then crops any excess outside the specified dimensions.
    #
    # The resulting image will always be exactly as large as the specified
    # dimensions.
    #
    # By default, the center part of the image is kept, and the remainder
    # cropped off, but this can be changed via the `gravity` option.
    #
    # @param [ImageProcesing::Pipeline] pipeline   processing pipeline to call
    # @param [#to_s] width                         the width to fill out
    # @param [#to_s] height                        the height to fill out
    # @param [String] gravity                      which part of the image to focus on
    # @return [Tempfile]
    # @see http://www.imagemagick.org/script/command-line-options.php#gravity
    def fill(pipeline, width, height, gravity = "Center")
      pipeline.resize_to_fill!(width, height, gravity: gravity)
    end

    # Resize the image to fit within the specified dimensions while retaining
    # the original aspect ratio in the same way as {#fill}. Unlike {#fill} it
    # will, if necessary, pad the remaining area with the given color, which
    # defaults to transparent where supported by the image format and white
    # otherwise.
    #
    # The resulting image will always be exactly as large as the specified
    # dimensions.
    #
    # By default, the image will be placed in the center but this can be
    # changed via the `gravity` option.
    #
    # @param [ImageProcesing::Pipeline] pipeline   processing pipeline to call
    # @param [#to_s] width                         the width to fill out
    # @param [#to_s] height                        the height to fill out
    # @param [string] background                   the color to use as a background
    # @param [string] gravity                      which part of the image to focus on
    # @return [Tempfile]
    # @see http://www.imagemagick.org/script/color.php
    # @see http://www.imagemagick.org/script/command-line-options.php#gravity
    def pad(pipeline, width, height, background = "transparent", gravity = "Center")
      pipeline.resize_and_pad!(width, height, gravity: gravity, background: background)
    end

    # Adjust the quality level of an JPEG/MIFF/PNG image to the specified
    # quality level.
    #
    # @param [ImageProcesing::Pipeline] pipeline   processing pipeline to call
    # @param [#to_s] level                         the JPEG/MIFF/PNG compression level
    # @return [Tempfile]
    # @see http://www.imagemagick.org/script/command-line-options.php#quality
    def quality(pipeline, level)
      pipeline.quality!(level)
    end

    # Resample the image to fit within the specified resolution while retaining
    # the original image size.
    #
    # The resulting image will always be the same pixel size as the source with
    # an adjusted resolution dimensions.
    #
    # @param [ImageProcesing::Pipeline] pipeline   processing pipeline to call
    # @param [#to_s] width                         the dpi width
    # @param [#to_s] height                        the dpi height
    # @return [Tempfile]
    # @see http://www.imagemagick.org/script/command-line-options.php#resample
    def resample(pipeline, width, height)
      pipeline.resample!("#{width}x#{height}")
    end

    # Process the given file. The file will be processed via one of the
    # instance methods of this class, depending on the `method` argument passed
    # to the constructor on initialization.
    #
    # If the format is given it will convert the image to the given file format.
    #
    # @param [File] file                  the file to manipulate
    # @param [String] format              the file format to convert to
    # @param [#to_s] quality              the quality level to apply
    # @yield [MiniMagick::Tool::Convert]
    # @return [Tempfile]                  the processed file
    def call(file, *args, format: nil, quality: nil, &block)
      pipeline = ImageProcessing::MiniMagick.source(file)
      pipeline = pipeline.convert(format) if format
      pipeline = pipeline.quality(quality) if quality
      pipeline = pipeline.custom(&block)

      send(@method, pipeline, *args)
    end
  end
end

[:fill, :fit, :limit, :pad, :convert, :quality, :resample].each do |name|
  Refile.processor(name, Refile::MiniMagick.new(name))
end
