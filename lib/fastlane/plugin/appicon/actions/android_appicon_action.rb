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
      
      def self.notification_icons(path, filename)
        return {} if !path || !filename
        
        {
          "#{path}-ldpi/#{filename}" => '36x36',
          "#{path}-mdpi/#{filename}" => '24x24',
          "#{path}-hdpi/#{filename}" => '36x36',
          "#{path}-xhdpi/#{filename}" => '48x48',
          "#{path}-xxhdpi/#{filename}" => '72x72',
          "#{path}-xxxhdpi/#{filename}" => '96x96',
        }
      end

      def self.run(params)
        fname = params[:appicon_image_file]
        notification_icon_path = params[:appicon_notification_icon_path]
        notification_icon_filename = params[:appicon_notification_icon_filename]
        custom_sizes = params[:appicon_custom_sizes]

        require 'mini_magick'
        image = MiniMagick::Image.open(fname)

        Helper::AppiconHelper.check_input_image_size(image, 512)

        # Convert image to png
        image.format 'png'
        
        # Merge notification icons into customer sizes as they are handled thes same way
        custom_sizes = self.notification_icons(notification_icon_path, notification_icon_filename).merge(custom_sizes)

        icons = Helper::AppiconHelper.get_needed_icons(params[:appicon_devices], self.needed_icons, true, custom_sizes)
        icons.each do |icon|
          width = icon['width']
          height = icon['height']

          # Custom icons will have basepath and filename already defined
          if icon.has_key?('basepath') && icon.has_key?('filename')
            basepath = Pathname.new(icon['basepath'])
            filename = icon['filename']  
          else
            basepath = Pathname.new("#{params[:appicon_path]}-#{icon['scale']}")
            filename = "#{params[:appicon_filename]}.png"
          end
          FileUtils.mkdir_p(basepath)

          image.resize "#{width}x#{height}"
          image.write basepath + filename
        end

        UI.success("Successfully stored launcher icons at '#{params[:appicon_path]}'")
      end
      
      def self.get_custom_sizes(image, custom_sizes)
        
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
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :appicon_notification_icon_path,
                                  env_name: "APPICON_NOTIFICATION_ICON_PATH",
                             default_value: 'app/res/drawable/',
                               description: "Path to res subfolder",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :appicon_notification_icon_filename,
                                  env_name: "APPICON_NOTIFICATION_ICON_FILENAME",
                             default_value: 'ic_stat_onesignal_default',
                               description: "File name for notification icons",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :appicon_custom_sizes,
                               description: "Hash of custom sizes - {'path/icon.png' => '256x256'}",
                                  optional: true,
                                      type: Hash)
        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end
    end
  end
end
