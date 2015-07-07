require 'spec_helper'

describe Dor::Release::Item do

  before :each do 
    
    @druid='oo000oo0001'
    @item=Dor::Release::Item.new(:druid=>@druid,:skip_heartbeat=>true) # skip heartbeat check for dor-fetcher
    @n=0

    # setup doubles and mocks so we can stub out methods and not make actual dor, webservice or workflow calls
    @client=instance_double(DorFetcher::Client)
    @response={'items'=>['returned_members'],'sets'=>['returned_sets'],'collections'=>['returned_collections']}
    allow(@client).to receive(:get_collection).and_return(@response)
    @item.fetcher = @client
    
    allow(Dor::Item).to receive(:find).and_return('dor_object')
    allow(Dor::Item).to receive(:initialize_workflow).and_return(true)
    allow(Dor::WorkflowService).to receive(:update_workflow_status).and_return(true)

  end
  
  it "should initialize" do
    expect(@item.druid).to eq @druid
  end
  
  it "should call dor::item.find, but only once" do
    expect(Dor::Item).to receive(:find).exactly(1).times
    while @n < 3 do
      expect(@item.object).to eq "dor_object"
      @n += 1
    end
  end
  
  it "should return false for republish_needed" do
    expect(@item.republish_needed?).to be_falsey
  end

  it "should call dor-fetcher-client to get the members, but only once" do
    expect(@item.fetcher).to receive(:get_collection).exactly(1).times
    while @n < 3 do
      expect(@item.members).to eq @response
      @n += 1
    end
  end
  
  it "should get the right value for item_members" do
    expect(@item.item_members).to eq @response['items']
  end

  it "should get the right value for sub_collections" do
    expect(@item.sub_collections).to eq @response['sets']+@response['collections']
  end  
  
end