require 'spec_helper'

describe Dor::Release::Item do
  before :each do
    @druid = 'oo000oo0001'
    @item = Dor::Release::Item.new(druid: @druid, skip_heartbeat: true) # skip heartbeat check for dor-fetcher
    @n = 0

    # setup doubles and mocks so we can stub out methods and not make actual dor, webservice or workflow calls
    @client = instance_double(DorFetcher::Client)
    @response = { 'items' => ['returned_members'], 'sets' => ['returned_sets'], 'collections' => ['returned_collections'] }
    allow(@client).to receive(:get_collection).and_return(@response)
    @item.fetcher = @client

    @dor_object = double(Dor::Item)
    allow(Dor::Item).to receive(:find).and_return(@dor_object)
    allow(@dor_object).to receive(:initialize_workflow).and_return(true)
    allow(Dor::Config.workflow.client).to receive(:update_workflow_status).and_return(true)
  end

  it 'should initialize' do
    expect(@item.druid).to eq @druid
  end

  it 'should call dor::item.find, but only once' do
    expect(Dor::Item).to receive(:find).with(@druid).and_return(@dor_object).exactly(1).times
    while @n < 3
      expect(@item.object).to eq @dor_object
      @n += 1
    end
  end

  it 'should return false for republish_needed' do
    expect(@item.republish_needed?).to be_falsey
  end

  it 'should call dor-fetcher-client to get the members, but only once' do
    expect(@item.fetcher).to receive(:get_collection).exactly(1).times
    while @n < 3
      expect(@item.members).to eq @response
      @n += 1
    end
  end

  it 'should get the right value for item_members' do
    expect(@item.item_members).to eq @response['items']
  end

  it 'should get the right value for sub_collections' do
    expect(@item.sub_collections).to eq @response['sets'] + @response['collections']
  end

  it 'should add the workflow for a collection' do
    expect(Dor::Item).to receive(:find).with(@druid).and_return(@dor_object).exactly(1).times
    expect(@dor_object).to receive(:initialize_workflow).with(Dor::Config.release.workflow_name).exactly(1).times
    Dor::Release::Item.add_workflow_for_collection(@druid)
  end

  it 'should add the workflow for an item' do
    expect(Dor::Item).to receive(:find).with(@druid).and_return(@dor_object).exactly(1).times
    expect(@dor_object).to receive(:initialize_workflow).with(Dor::Config.release.workflow_name).exactly(1).times
    expect(Dor::Config.workflow.client).to receive(:update_workflow_status).exactly(1).times
    Dor::Release::Item.add_workflow_for_item(@druid)
  end
  
  it 'should make a webservice call for updating_marc_records' do
    stub_request(:post, "https://example.com/dor/v1/objects/oo000oo0001/update_marc_record").
             with(headers: {'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'Authorization' => 'Basic VVNFUk5BTUU6UEFTU1dPUkQ='}).
             to_return(status: 201, body: "", headers: {})
    expect(@item.update_marc_record).to eq(201)
  end

  it 'should return correct object types, assuming the values are set in the identityMetadata correctly' do
    allow(@item).to receive(:object_type).and_return('item')
    expect(@item.is_item?).to be_truthy
    expect(@item.is_collection?).to be_falsey
    expect(@item.is_set?).to be_falsey
    expect(@item.is_apo?).to be_falsey

    allow(@item).to receive(:object_type).and_return('set')
    expect(@item.is_item?).to be_falsey
    expect(@item.is_collection?).to be_falsey
    expect(@item.is_set?).to be_truthy
    expect(@item.is_apo?).to be_falsey

    allow(@item).to receive(:object_type).and_return('collection')
    expect(@item.is_item?).to be_falsey
    expect(@item.is_collection?).to be_truthy
    expect(@item.is_set?).to be_falsey
    expect(@item.is_apo?).to be_falsey

    allow(@item).to receive(:object_type).and_return('adminPolicy')
    expect(@item.is_item?).to be_falsey
    expect(@item.is_collection?).to be_falsey
    expect(@item.is_set?).to be_falsey
    expect(@item.is_apo?).to be_truthy
  end
end
