# Make sure specs run with the definitions from test.rb
ENV['ROBOT_ENVIRONMENT'] = 'test'

require 'simplecov'
require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.order = 'random'
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                 SimpleCov::Formatter::HTMLFormatter,
                                                                 Coveralls::SimpleCov::Formatter
                                                               ])

bootfile = File.expand_path(File.dirname(__FILE__) + '/../config/boot')
require bootfile

require 'pry'
require 'rspec'
require 'webmock/rspec'

def setup_release_item(druid, obj_type, members)
  @release_item = Dor::Release::Item.new(druid: druid, skip_heartbeat: true)
  @dor_item = instance_double(Dor::Item)
  allow(@dor_item).to receive_messages(
    publish_metadata: nil,
    id: druid
  )
  allow(@release_item).to receive_messages(
    object: @dor_item,
    object_type: obj_type.to_s.downcase,
    "is_item?": (obj_type == :item),
    "is_collection?": (obj_type == :collection),
    "is_set?": (obj_type == :set),
    "is_apo?": (obj_type == :apo),
    members: members
  )
  allow(Dor::Release::Item).to receive_messages(new: @release_item)
end
