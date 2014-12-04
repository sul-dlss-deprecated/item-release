require 'spec_helper'

describe Robots::DorRepo::ItemRelease::ReleaseMembers do

  before :each do
    @druid='aa222cc3333'
    setup_work_item(@druid)
    @r = Robots::DorRepo::ItemRelease::ReleaseMembers.new
  end  

  it "should run the robot" do
    setup_release_item(@druid,:item)
    @r.perform(@work_item)
  end

  it "should run the robot for an item or an apo and do nothing as a result" do
    %w{:item :apo}.each do |item_type|
      setup_release_item(@druid,item_type)
      expect(@release_item.is_collection?).to be false # definitely not a collection
      expect(@r).to_not receive(:item_members) # we won't bother looking for item members if this is an item
      @r.perform(@work_item)
    end
  end
  
  it "should run for a collection and execute the item_members method" do
    setup_release_item(@druid,:collection)
    expect(@release_item.is_collection?).to be true
    expect(@release_item).to receive(:item_members).once # we should be looking up the members
    @r.perform(@work_item)
  end
    
end