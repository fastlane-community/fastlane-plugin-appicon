require 'json'
require 'mini_magick'

module Fastlane
  module Actions
    class AppiconAction < Action
      def self.needed_icons
        {
          universal: {
            '1x' => ['2732x2732'],
            '2x' => ['2732x2732'],
            '3x' => ['2732x2732']
          },
          iphone: {
            '2x' => ['20x20', '29x29', '40x40', '60x60'],
            '3x' => ['20x20', '29x29', '40x40', '60x60']
          },
          ipad: {
            '1x' => ['20x20', '29x29', '40x40', '76x76'],
            '2x' => ['20x20', '29x29', '40x40', '76x76', '83.5x83.5']
          },
          :ios_marketing => {
            '1x' => ['1024x1024']
          },
          :watch => {
            '2x' => [
                      ['24x24', 'notificationCenter', '38mm'],
                      ['27.5x27.5', 'notificationCenter', '42mm'],
                      ['29x29', 'companionSettings'],
                      ['40x40', 'appLauncher', '38mm'],
                      ['44x44', 'appLauncher', '40mm'],
                      ['50x50', 'appLauncher', '44mm'],
                      ['86x86', 'quickLook', '38mm'],
                      ['98x98', 'quickLook', '42mm'],
                      ['108x108', 'quickLook', '44mm']
                    ],
            '3x' => [['29x29', 'companionSettings']]
          },
          :watch_marketing => {
            '1x' => ['1024x1024']
          },
          :macos => {
            '1x' => ['16x16', '32x32', '128x128', '256x256', '512x512'],
            '2x' => ['16x16', '32x32', '128x128', '256x256', '512x512'],
          },
          :tvos => {
            '1x' => ['400x240'],
            '2x' => ['800x480']
          }
        }
      end

      def self.needed_icons_messages_extension
        {
          iphone: {
            '2x' => ['60x45'],
            '3x' => ['60x45']
          },
          ipad: {
            '2x' => ['67x50', '74x55']
          },
          messages: {
            '2x' => ['27x20', '32x24'],
            '3x' => ['27x20', '32x24']
          },
          ios_marketing: {
            '1x' => ['1024x768']
          }
        }
      end

      def self.run(params)
        fname = params[:appicon_image_file]
        basename = File.basename(fname, File.extname(fname))

        Helper::AppiconHelper.set_cli(params[:minimagick_cli])

        is_messages_extension = params[:messages_extension]
        basepath = Pathname.new(File.join(params[:appicon_path], is_messages_extension ? params[:appicon_messages_name] : params[:appicon_name]))
        
        image = MiniMagick::Image.open(fname)

        if is_messages_extension
          Helper::AppiconHelper.check_input_image_size(image, 1024, 768)
        else
          Helper::AppiconHelper.check_input_image_size(image, 1024, 1024)
        end

        # Convert image to png
        image.format 'png'

        # remove alpha channel
        if params[:remove_alpha]
          image.alpha 'remove'
        end

        # Recreate the base path
        FileUtils.rm_rf(basepath)
        FileUtils.mkdir_p(basepath)

        images = []

        icons = Helper::AppiconHelper.get_needed_icons(params[:appicon_devices], is_messages_extension ? self.needed_icons_messages_extension : self.needed_icons, false)
        icons.each do |icon|
          width = icon['width']
          height = icon['height']
          filename = basename
          unless icon['device'] == 'universal'
            filename += "-#{width.to_i}x#{height.to_i}"
          end
          filename += ".png"

          # downsize icon
          # "!" resizes to exact size (needed for messages extension)
          image.resize "#{width}x#{height}!"

          # Don't write change/created times into the PNG properties
          # so unchanged files don't have different hashes.
          image.define("png:exclude-chunks=date,time")

          image.write basepath + filename

          info = {
            'idiom' => icon['device'],
            'filename' => filename,
            'scale' => icon['scale']
          }

          # if device is messages, we need to set it to universal
          if icon['device'] == 'messages'
            info['idiom'] = 'universal'
            info['platform'] = 'ios'
          end

          # if device is ios_marketing but we are generating messages extension app, set the idiom correctly
          if icon['device'] == 'ios_marketing' && is_messages_extension
            info['platform'] = 'ios'
          end
          

          unless icon['device'] == 'universal'
            info['size'] = icon['size']
          end

          info['role'] = icon['role'] unless icon['role'].nil?
          info['subtype'] = icon['subtype'] unless icon['subtype'].nil?

          images << info
        end

        contents = {
          'images' => images,
          'info' => {
            'version' => 1,
            'author' => 'fastlane'
          }
        }

        File.write(File.join(basepath, 'Contents.json'), JSON.pretty_generate(contents))
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
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :appicon_messages_name,
                                  env_name: "APPICON_MESSAGES_NAME",
                             default_value: 'AppIcon.stickersiconset',
                               description: "Name of the appiconset inside the asset catalogue",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :remove_alpha,
                                  env_name: "REMOVE_ALPHA",
                             default_value: false,
                               description: "Remove the alpha channel from generated PNG",
                                  optional: true,
                                      type: Boolean),
          FastlaneCore::ConfigItem.new(key: :messages_extension,
                                  env_name: "APPICON_MESSAGES_EXTENSION",
                             default_value: false,
                               description: "App icon is generated for Messages extension",
                                  optional: true,
                                      type: Boolean),
          FastlaneCore::ConfigItem.new(key: :minimagick_cli,
                                  env_name: "APPICON_MINIMAGICK_CLI",
                               description: "Set MiniMagick CLI (auto picked by default). Values are: graphicsmagick, imagemagick",
                                  optional: true,
                                      type: String,
                              verify_block: proc do |value|
                                        av = %w(graphicsmagick imagemagick)
                                        UI.user_error!("Unsupported minimagick cli '#{value}', must be: #{av}") unless av.include?(value)
                                      end)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac, :macos, :caros, :rocketos].include?(platform)
      end
    end
  end
end
