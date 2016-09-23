# Make sure specs run with the definitions from test.rb
ENV['ROBOT_ENVIRONMENT'] = 'test'

require 'simplecov'
require 'coveralls'
Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

bootfile = File.expand_path(File.dirname(__FILE__) + '/../config/boot')
require bootfile

require 'pry'
require 'rspec'
require 'webmock/rspec'

def setup_work_item(druid)
  @work_item=double("work_item")
  allow(@work_item).to receive_messages(:druid=>druid)
end

def setup_release_item(druid,obj_type,item_members=nil)
  @release_item=double(Dor::Release::Item)
  @dor_item=double(Dor::Item)
  allow(@dor_item).to receive_messages(
    :publish_metadata=>nil,
    :id=>druid
      )
  allow(@release_item).to receive_messages(
      :druid=>druid,
      :object=>@dor_item,
      :object_type=>obj_type.to_s.downcase,
      :"is_item?"=>(obj_type==:item),
      :"is_collection?"=>(obj_type==:collection),
      :"is_set?"=>(obj_type==:set),
      :"is_apo?"=>(obj_type==:apo),
      :item_members=>item_members,
    )
  allow(Dor::Release::Item).to receive_messages(:new=>@release_item)
end
