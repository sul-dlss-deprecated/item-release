require 'spec_helper'

describe Dor::UpdateMarcRecordService do
  
  before :all do
    @fixtures = "spec/fixtures/"
  end
  
  describe ".push_symphony_record" do
    pending
  end

  describe ".generate_symphony_record" do
    it "should generate symphony record for a druid object with catkey" do
      Dor::Config.release.purl_base_uri = "http://purl.stanford.edu"

      item=double(Dor::Item.new)
      collection = double(Dor::Collection.new)
      identityMetadataXML = double(String)
      
      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_1)
      )
      
      allow(collection).to receive_messages(
        :label => "Collection label",
        :id => "druid:cc111cc1111",
      )
      
      allow(item).to receive_messages(
        :id => "druid:aa111aa1111",
        :collections =>[collection],
        :datastreams => {"identityMetadata"=>identityMetadataXML} 
      )
      updater = Dor::UpdateMarcRecordService.new(item)
      expect(updater.generate_symphony_record).to eq("8832162\t.856. 41|uhttp://purl.stanford.edu/aa111aa1111|xSDR-PURL|xdruid:cc111cc1111:Collection label")
    end
    
    it "should generate symphony record for a collection object with catkey" do
      Dor::Config.release.purl_base_uri = "http://purl.stanford.edu"

      item=double(Dor::Item.new)
      identityMetadataXML = double(String)
      
      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_1)
      )
      
      allow(item).to receive_messages(
        :label => "Collection label",
        :id => "druid:aa111aa1111",
        :collections =>[],
        :datastreams => {"identityMetadata"=>identityMetadataXML} 
       )
     
      updater = Dor::UpdateMarcRecordService.new(item)
      expect(updater.generate_symphony_record).to eq("8832162\t.856. 41|uhttp://purl.stanford.edu/aa111aa1111|xSDR-PURL")
    end
  end

  describe ".write_symphony_record" do
    it "should write the symphony record to the symphony directory" do
      d = Dor::Item.new 
      updater = Dor::UpdateMarcRecordService.new(d)
      updater.instance_variable_set(:@druid_id,"druid:aa111aa1111")
      Dor::Config.release.symphony_path = "#{@fixtures}/sdr_purl"
      updater.write_symphony_record "aaa"
    
      expect(Dir.glob("#{@fixtures}/sdr_purl/sdr-purl-aa111aa1111-??????????????").empty?).to be false
    end
    
    it "should do nothing if the symphony record is empty" do
      d = Dor::Item.new 
      updater = Dor::UpdateMarcRecordService.new(d)
      updater.instance_variable_set(:@druid_id,"druid:aa111aa1111")
      Dor::Config.release.symphony_path = "#{@fixtures}/sdr_purl"
      updater.write_symphony_record ""
    
      expect(Dir.glob("#{@fixtures}/sdr_purl/sdr-purl-aa111aa1111-??????????????").empty?).to be true
    end
  
    it "should do nothing if the symphony record is nil" do
      d = Dor::Item.new 
      updater = Dor::UpdateMarcRecordService.new(d)
      updater.instance_variable_set(:@druid_id,"druid:aa111aa1111")
      Dor::Config.release.symphony_path = "#{@fixtures}/sdr_purl"
      updater.write_symphony_record ""
    
      expect(Dir.glob("#{@fixtures}/sdr_purl/sdr-purl-aa111aa1111-??????????????").empty?).to be true
    end
  
    after :each do
      FileUtils.rm_rf("#{@fixtures}/sdr_purl/.")
    end
  end

  describe ".get_ckey" do
    it "should return catkey from a valid identityMetadata" do
      identityMetadataXML = Nokogiri::XML(build_identity_metadata_1)
      d = Dor::Item.new 
      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.get_ckey identityMetadataXML).to eq("8832162")
    end
    
    it "should return nil for an identityMetadata without catkey" do
      identityMetadataXML = Nokogiri::XML(build_identity_metadata_2)
      d = Dor::Item.new 
      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.get_ckey identityMetadataXML).to be_nil
    end
  end

  describe ".get_856_cons" do
    it "should return a valid sdrpurl constant" do
      d = Dor::Item.new 
      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.get_856_cons).to eq(".856.")
    end
  end

  describe ".get_1st_indicator" do     
    it "should return 4" do
      d = Dor::Item.new 
      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.get_1st_indicator).to eq("4")
    end
  end

  describe ".get_2nd_indicator" do 
    it "should return 1" do
      d = Dor::Item.new 
      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.get_2nd_indicator).to eq("1")
    end
  end

  describe ".get_u_field" do
    it "should return valid purl url" do
      d = Dor::Item.new 
      updater = Dor::UpdateMarcRecordService.new(d)
      updater.instance_variable_set(:@druid_id,"druid:aa111aa1111")
      Dor::Config.release.purl_base_uri = "http://purl.stanford.edu"
      expect(updater.get_u_field).to eq("|uhttp://purl.stanford.edu/aa111aa1111")
    end
  end

  describe ".get_x1_sdrpurl_marker" do
    it "should return a valid sdrpurl constant" do
      d = Dor::Item.new 
      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.get_x1_sdrpurl_marker).to eq("|xSDR-PURL")
    end
  end

  describe ".get_x2_collection_info" do
    it "should return an empty string for an object without collection" do
      d = Dor::Item.new 
      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.get_x2_collection_info).to eq("")
    end

    it "should return an empty string for a collection object" do
      c = Dor::Collection.new    
      updater = Dor::UpdateMarcRecordService.new(c)
      expect(updater.get_x2_collection_info).to eq("")
    end

    it "should return an empty string for a collection object" do
      item=double(Dor::Item.new)
      collection = double(Dor::Collection.new)
      
      allow(collection).to receive_messages(
        :label => "Collection label",
        :id => "druid:cc111cc1111",
      )
      
      allow(item).to receive_messages(
        :id => "druid:aa111aa1111",
        :collections =>[collection],
      )
      updater = Dor::UpdateMarcRecordService.new(item)
      expect(updater.get_x2_collection_info).to eq("|xdruid:cc111cc1111:Collection label")
    end
  end
  
  def build_identity_metadata_1
    identityMetadataXML = '<identityMetadata>
  <sourceId source="sul">36105216275185</sourceId>
  <objectId>druid:bb987ch8177</objectId>
  <objectCreator>DOR</objectCreator>
  <objectLabel>A  new map of Africa</objectLabel>
  <objectType>item</objectType>
  <adminPolicy>druid:dd051ys2703</adminPolicy>
  <otherId name="catkey">8832162</otherId>
  <otherId name="barcode">36105216275185</otherId>
  <otherId name="uuid">ff3ce224-9ffb-11e3-aaf2-0050569b3c3c</otherId>
  <tag>Process : Content Type : Map</tag>
  <tag>Project : Batchelor Maps : Batch 1</tag>
  <tag>LAB : MAPS</tag>
  <tag>Registered By : dfuzzell</tag>
  <tag>Remediated By : 4.15.4</tag>
</identityMetadata>'
  end
  def build_identity_metadata_2
    identityMetadataXML = '<identityMetadata>
  <sourceId source="sul">36105216275185</sourceId>
  <objectId>druid:bb987ch8177</objectId>
  <objectCreator>DOR</objectCreator>
  <objectLabel>A  new map of Africa</objectLabel>
  <objectType>item</objectType>
  <adminPolicy>druid:dd051ys2703</adminPolicy>
  <otherId name="barcode">36105216275185</otherId>
  <otherId name="uuid">ff3ce224-9ffb-11e3-aaf2-0050569b3c3c</otherId>
  <tag>Process : Content Type : Map</tag>
  <tag>Project : Batchelor Maps : Batch 1</tag>
  <tag>LAB : MAPS</tag>
  <tag>Registered By : dfuzzell</tag>
  <tag>Remediated By : 4.15.4</tag>
</identityMetadata>'
  end
end