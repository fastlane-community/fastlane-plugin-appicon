module Fastlane
  module Actions
    class AppiconAction < Action
      def self.needed_icons
        {
          iphone: {
            '2x' => ['20x20', '29x29', '40x40', '60x60'],
            '3x' => ['20x20', '29x29', '40x40', '60x60']
          },
          ipad: {
            '1x' => ['20x20', '29x29', '40x40', '76x76'],
            '2x' => ['20x20', '29x29', '40x40', '76x76', '83.5x83.5']
          },
          :'ios-marketing' => {
            '1x' => ['1024x1024']
          }
        }
      end

      def self.run(params)
        fname = params[:appicon_image_file]
        basename = File.basename(fname, File.extname(fname))
        basepath = Pathname.new(File.join(params[:appicon_path], params[:appicon_name]))

        require 'mini_magick'
        image = MiniMagick::Image.open(fname)

        Helper::AppiconHelper.check_input_image_size(image, 1024)

        # Convert image to png
        image.format 'png'

        # Create the base path
        FileUtils.mkdir_p(basepath)

        images = []

        icons = Helper::AppiconHelper.get_needed_icons(params[:appicon_devices], self.needed_icons, false)
        icons.each do |icon|
          width = icon['width']
          height = icon['height']
          filename = "#{basename}-#{width.to_i}x#{height.to_i}.png"

          # downsize icon
          image.resize "#{width}x#{height}"
          image.write basepath + filename

          images << {
            'size' => icon['size'],
            'idiom' => icon['device'],
            'filename' => filename,
            'scale' => icon['scale']
          }
        end

        contents = {
          'images' => images,
          'info' => {
            'version' => 1,
            'author' => 'fastlane'
          }
        }

        require 'json'
        File.write(File.join(basepath, 'Contents.json'), JSON.dump(contents))
        UI.success("Successfully stored app icon at '#{basepath}'")
      end

      def self.description
        "Generate required icon sizes and iconset from a master application icon"
      end

      def self.authors
        ["@NeoNacho"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :appicon_image_file,
                                  env_name: "APPICON_IMAGE_FILE",
                               description: "Path to a square image file, at least 1024x1024",
                                  optional: false,
                                      type: String,
                             default_value: Dir["fastlane/metadata/app_icon.png"].last), # that's the default when using fastlane to manage app metadata
          FastlaneCore::ConfigItem.new(key: :appicon_devices,
                                  env_name: "APPICON_DEVICES",
                             default_value: [:iphone],
                               description: "Array of device idioms to generate icons for",
                                  optional: true,
                                      type: Array),
          FastlaneCore::ConfigItem.new(key: :appicon_path,
                                  env_name: "APPICON_PATH",
                             default_value: 'Assets.xcassets',
                               description: "Path to the Asset catalogue for the generated iconset",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :appicon_name,
                                  env_name: "APPICON_NAME",
                             default_value: 'AppIcon.appiconset',
                               description: "Name of the appiconset inside the asset catalogue",
                                  optional: true,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac, :macos, :caros, :rocketos].include?(platform)
      end
    end
  end
end
