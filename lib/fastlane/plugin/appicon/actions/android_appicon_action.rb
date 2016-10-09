module Fastlane
  module Actions
    class AndroidAppiconAction < Action
      def self.needed_icons
        {
          phone: {
            'ldpi' => ['36x36'],
            'mdpi' => ['48x48'],
            'hdpi' => ['72x72'],
            'xhdpi' => ['96x96']
          },
          tablet: {
            'xxhdpi' => ['144x144'],
            'xxxhdpi' => ['192x192']
          }
        }
      end

      def self.run(params)
        fname = params[:appicon_image_file]

        require 'mini_magick'
        image = MiniMagick::Image.open(fname)

        UI.user_error!("Minimum width of input image should be 512") if image.width < 512
        UI.user_error!("Minimum height of input image should be 512") if image.height < 512
        UI.user_error!("Input image should be square") if image.width != image.height

        params[:appicon_devices].each do |device|
          self.needed_icons[device].each do |scale, sizes|
            sizes.each do |size|
              width, height = size.split('x').map { |v| v.to_f * scale.to_i }

              basepath = Pathname.new("#{params[:appicon_path]}-#{scale}")
              FileUtils.mkdir_p(basepath)
              filename = "#{params[:appicon_filename]}.png"

              image = MiniMagick::Image.open(fname)
              image.format 'png'
              image.resize "#{width}x#{height}"
              image.write basepath + filename
            end
          end
        end

        UI.success("Successfully stored launcher icons at '#{params[:appicon_path]}'")
      end

      def self.description
        "Generate required icon sizes from a master application icon"
      end

      def self.authors
        ["@adrum"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :appicon_image_file,
                                  env_name: "APPICON_IMAGE_FILE",
                               description: "Path to a square image file, at least 512x512",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :appicon_devices,
                                  env_name: "APPICON_DEVICES",
                             default_value: [:phone],
                               description: "Array of device types to generate icons for",
                                  optional: true,
                                      type: Array),
          FastlaneCore::ConfigItem.new(key: :appicon_path,
                                  env_name: "APPICON_PATH",
                             default_value: 'app/res/mipmap/',
                               description: "Path to res subfolder",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :appicon_filename,
                                  env_name: "APPICON_FILENAME",
                             default_value: 'ic_launcher',
                               description: "The output filename of each image",
                                  optional: true,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end
    end
  end
end
