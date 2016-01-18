#
# Be sure to run `pod lib lint NBReorderTableView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "NBReorderTableView"
  s.version          = "0.1.3"
  s.summary          = "Reorder table view cells with long press."
  s.description      = <<-DESC
                       NBReorderTableView is a `UITableView` subclass to support reordering cells with long press.
                       DESC
  s.homepage         = "https://github.com/nunobaldaia/NBReorderTableView"
  s.screenshots     = "https://raw.githubusercontent.com/nunobaldaia/NBReorderTableView/master/screenshot.png"
  s.license          = 'MIT'
  s.author           = { "Nuno Baldaia" => "nunobaldaia@gmail.com" }
  s.source           = { :git => "https://github.com/nunobaldaia/NBReorderTableView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/nunobaldaia'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
end
