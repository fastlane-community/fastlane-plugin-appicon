module Fastlane
  module Helper
    class AppiconHelper
      def self.check_input_image_size(image, size)
        UI.user_error!("Minimum width of input image should be #{size}") if image.width < size
        UI.user_error!("Minimum height of input image should be #{size}") if image.height < size
        UI.user_error!("Input image should be square") if image.width != image.height
      end
      def self.get_needed_icons(devices, needed_icons, is_android = false)
        icons = []
        devices.each do |device|
          needed_icons[device].each do |scale, sizes|
            sizes.each do |size|
              if is_android
                width, height = size.split('x').map { |v| v.to_f }
              else
                width, height = size.split('x').map { |v| v.to_f * scale.to_i }
              end

              icons << {
                'width' => width,
                'height' => height,
                'size' => size,
                'device' => device,
                'scale' => scale
              }
            end
          end
        end
        # Sort from the largest to the smallest needed icon
        icons = icons.sort_by {|value| value['width']} .reverse
      end
    end
  end
end
