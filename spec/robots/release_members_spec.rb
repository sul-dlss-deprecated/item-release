require 'spec_helper'

describe Robots::DorRepo::ItemRelease::ReleaseMembers do

  before :each do
    @druid='aa222cc3333'
    setup_work_item(@druid)
    @r = Robots::DorRepo::ItemRelease::ReleaseMembers.new
    allow(RestClient).to receive_messages(:post=>nil,:get=>nil,:put=>nil) # don't actually make the RestClient calls, just assume they work
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
    item_members=[{"druid"=>"druid:bb001zc5754", "latest_change"=>"2014-06-06T05:06:06Z", "title"=>"French Grand Prix and 12 Hour Rheims: 1954", "catkey"=>"3051728"},
     {"druid"=>"druid:bb023nj3137", "latest_change"=>"2014-06-06T05:06:06Z", "title"=>"Snetterton Vanwall Trophy: 1958", "catkey"=>"3051732"},
     {"druid"=>"druid:bb027yn4436", "latest_change"=>"2014-06-06T05:06:06Z", "title"=>"Crystal Palace BARC: 1954", "catkey"=>"3051733"},
     {"druid"=>"druid:bb048rn5648", "latest_change"=>"2014-06-06T05:06:06Z", "title"=>"", "catkey"=>"3051734"}]
    setup_release_item(@druid,:collection,item_members)
    expect(@release_item.is_collection?).to be true
    expect(@release_item.item_members).to eq(item_members)
    expect(@release_item).to receive(:item_members).twice # we should be looking up the members (first time to see if any items exist, second type to iterate)
    expect(Dor::ItemRelease::Item).to receive(:add_workflow_for_item).exactly(4).times
    @r.perform(@work_item)
  end
    
end