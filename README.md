# appicon plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-appicon)

![Demo image](demo.png)

## Getting Started

This project is a [fastlane](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-appicon`, add it to your project by running:

```bash
fastlane add_plugin appicon
```

## About appicon

Generate required icon sizes and iconset from a master application icon. 

Since many apps use a single 1024x1024 icon to produce all the required sizes from, why not automate the process and save lots of time?

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

Just specify the source image using the `appicon_image_file`. Optionally specify the devices  using `appicon_devices` and the destination path using `appicon_path`.

```ruby
lane :test do
  appicon(appicon_image_file: 'spec/fixtures/Themoji.png',
    appicon_devices: [:ipad, :iphone])
end
```

## Run tests for this plugin

To run both the tests, and code style validation, run

````
rake
```

To automatically fix many of the styling issues, use 
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/PluginsTroubleshooting.md) doc in the main `fastlane` repo.

## Using `fastlane` Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Plugins.md).

## About `fastlane`

`fastlane` is the easiest way to automate building and releasing your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
