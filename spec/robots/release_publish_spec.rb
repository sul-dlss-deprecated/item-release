require 'spec_helper'

describe Robots::DorRepo::ItemRelease::ReleasePublish do

  before :each do
    @druid='aa222cc3333'
    setup_work_item(@druid)
    @r = Robots::DorRepo::ItemRelease::ReleasePublish.new
  end  

  it "should run the robot when a republish is needed, calling publish metadata on the dor item" do
    setup_release_item(@druid,:item)
    allow(@release_item).to receive_messages(
        :"republish_needed?"=>true
      )
    expect(@release_item).to receive(:"republish_needed?").once
    expect(@dor_item).to receive(:publish_metadata).once
    @r.perform(@work_item)
  end

  it "should run the robot when a republish is not needed, not calling publish metadata on the dor item" do
    setup_release_item(@druid,:item)
    allow(@release_item).to receive_messages(
        :"republish_needed?"=>false
      )
    expect(@release_item).to receive(:"republish_needed?").once
    expect(@dor_item).to_not receive(:publish_metadata)
    @r.perform(@work_item)
  end

    
end