require 'spec_helper'

describe Robots::DorRepo::ItemRelease::ReleasePublish do

  before :each do
    @druid='aa222cc3333'
    setup_work_item(@druid)
    @r = Robots::DorRepo::ItemRelease::ReleasePublish.new
  end  

  it "should run the robot" do
    setup_release_item(@druid,:item)
    @r.perform(@work_item)
  end
    
end