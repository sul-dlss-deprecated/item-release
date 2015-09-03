require 'spec_helper'

describe Robots::DorRepo::Release::UpdateMarc do

  before :all do
    Dor::Config.release.write_marc_script = 'bin/write_marc_record_test'
    Dor::Config.release.symphony_path = './spec/fixtures/sdr-purl'
    Dor::Config.release.purl_base_uri = "http://purl.stanford.edu"
  end

  before :each do
    @druid='aa222cc3333'
    @umr = Robots::DorRepo::Release::UpdateMarc.new
  end

  context "for a druid without a catkey" do
    it 'does nothing' do
      setup_release_item(@druid,:item)
      umrs=Dor::UpdateMarcRecordService.new @dor_item
      allow(Dor::Item).to receive(:find).with(@druid).and_return(@dor_item)
      allow(umrs).to receive(:ckey).with(@dor_item).and_return(:nil)
      expect(@dor_item).to receive(:datastreams).with(no_args)
      expect(umrs).not_to receive(:push_symphony_record)
      @umr.perform(@druid)
    end
  end

  context "for a druid with a catkey" do
    it "Executes the UpdateMarcRecordService push_symphony_record method" do
      identityMetadataXML = Dor::IdentityMetadataDS.new
      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_1)
      )
      dor_item=Dor::Item.new
      allow(dor_item).to receive_messages(
        :id=>@druid,
        :datastreams => {"identityMetadata"=>identityMetadataXML}
      )
      umrs=Dor::UpdateMarcRecordService.new dor_item
      allow(Dor::UpdateMarcRecordService).to receive_messages(:new=>umrs)
      allow(Dor::Item).to receive(:find).with(@druid).and_return(dor_item)
      allow(umrs).to receive(:ckey).with(dor_item).and_return('8832162')
      expect(umrs).to receive(:push_symphony_record)
      @umr.perform(@druid)
    end
  end
end

def build_identity_metadata_1
      identityMetadataXML = '<identityMetadata>
  <sourceId source="sul">36105216275185</sourceId>
  <objectId>druid:bb987ch8177</objectId>
  <objectCreator>DOR</objectCreator>
  <objectLabel>A  new map of Africa</objectLabel>
  <objectType>item</objectType>
  <displayType>image</displayType>
  <adminPolicy>druid:dd051ys2703</adminPolicy>
  <otherId name="catkey">8832162</otherId>
  <otherId name="uuid">ff3ce224-9ffb-11e3-aaf2-0050569b3c3c</otherId>
  <tag>Process : Content Type : Map</tag>
  <tag>Project : Batchelor Maps : Batch 1</tag>
  <tag>LAB : MAPS</tag>
  <tag>Registered By : dfuzzell</tag>
  <tag>Remediated By : 4.15.4</tag>
</identityMetadata>'
end
