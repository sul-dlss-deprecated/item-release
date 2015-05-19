require 'spec_helper'

describe Dor::UpdateMarcRecordService do
  
  before :all do
    @fixtures = "spec/fixtures/"
  end
  
  describe ".push_symphony_record" do
    pending
  end

  describe ".generate_symphony_record" do
    it "should generate an empty string for a druid object without catkey" do
      Dor::Config.release.purl_base_uri = "http://purl.stanford.edu"

      item=double(Dor::Item.new)
      collection = double(Dor::Collection.new)
      identityMetadataXML = double(String)

      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_3)
      )

      allow(collection).to receive_messages(
        :label => "Collection label",
        :id => "cc111cc1111",
        :catkey => "12345678"
      )

      allow(item).to receive_messages(
        :id => "aa111aa1111",
        :collections =>[collection],
        :datastreams => {"identityMetadata"=>identityMetadataXML}
      )
      updater = Dor::UpdateMarcRecordService.new(item)
      expect(updater.generate_symphony_record).to eq("")
    end
    it "should generate symphony record for a item object with catkey" do
      Dor::Config.release.purl_base_uri = "http://purl.stanford.edu"

      item=double(Dor::Item.new)
      collection = double(Dor::Collection.new)
      identityMetadataXML = double(String)
      contentMetadataXML = double(String)

      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_1)
      )

      allow(contentMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_content_metadata_1)
      )

      allow(collection).to receive_messages(
        :label => "Collection label",
        :id => "cc111cc1111",
        :catkey => nil
      )

      allow(item).to receive_messages(
        :id => "aa111aa1111",
        :collections =>[collection],
        :datastreams => {"identityMetadata"=>identityMetadataXML, "contentMetadata"=>contentMetadataXML}
      )
      updater = Dor::UpdateMarcRecordService.new(item)
      expect(updater.generate_symphony_record).to eq("8832162\t.856. 41|uhttp://purl.stanford.edu/aa111aa1111|xSDR-PURL|xitem|ximage|x36105216275185|xwt183gy6220_00_0001.jp2|xcc111cc1111::Collection label")
    end
    
    it "should generate symphony record for a collection object with catkey" do
      Dor::Config.release.purl_base_uri = "http://purl.stanford.edu"

      item=double(Dor::Item.new)
      identityMetadataXML = double(String)
      contentMetadataXML = double(String)
      
      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_2)
      )

      allow(contentMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_content_metadata_2)
      )

      allow(item).to receive_messages(
        :label => "Collection label",
        :id => "aa111aa1111",
        :collections =>[],
        :datastreams => {"identityMetadata"=>identityMetadataXML, "contentMetadata"=>contentMetadataXML}
       )
     
      updater = Dor::UpdateMarcRecordService.new(item)
      expect(updater.generate_symphony_record).to eq("8832162\t.856. 41|uhttp://purl.stanford.edu/aa111aa1111|xSDR-PURL|xcollection|x|x|xwt183gy6220_00_0001.jp2,wt183gy6220_00_0002.jp2")
    end
  end

  describe ".write_symphony_record" do
    xit "should write the symphony record to the symphony directory" do
      d = Dor::Item.new 
      updater = Dor::UpdateMarcRecordService.new(d)
      updater.instance_variable_set(:@druid_id,"aa111aa1111")
      Dor::Config.release.symphony_path = "#{@fixtures}/sdr_purl"
      Dor::Config.release.write_marc_script = "bin/write_marc_record_test"
      updater.write_symphony_record "aaa"
      
      expect(Dir.glob("#{@fixtures}/sdr_purl/sdr-purl-aa111aa1111-??????????????").empty?).to be false
   end    
    
    it "should do nothing if the symphony record is empty" do
      d = Dor::Item.new 
      updater = Dor::UpdateMarcRecordService.new(d)
      updater.instance_variable_set(:@druid_id,"aa111aa1111")
      Dor::Config.release.symphony_path = "#{@fixtures}/sdr_purl"
      updater.write_symphony_record ""
      
      expect(Dir.glob("#{@fixtures}/sdr_purl/sdr-purl-aa111aa1111-??????????????").empty?).to be true
    end
  
    it "should do nothing if the symphony record is nil" do
      d = Dor::Item.new 
      updater = Dor::UpdateMarcRecordService.new(d)
      updater.instance_variable_set(:@druid_id,"aa111aa1111")
      Dor::Config.release.symphony_path = "#{@fixtures}/sdr_purl"
      updater.write_symphony_record ""
    
      expect(Dir.glob("#{@fixtures}/sdr_purl/sdr-purl-aa111aa1111-??????????????").empty?).to be true
    end
  
    after :each do
      FileUtils.rm_rf("#{@fixtures}/sdr_purl/.")
    end
  end

  describe ".catkey" do
    it "should return catkey from a valid identityMetadata" do
      identityMetadataXML = double(String)
      
      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_1)
      )
      
      d = Dor::Item.new 

      allow(d).to receive_messages(
        :datastreams => {"identityMetadata"=>identityMetadataXML} 
      )

      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.catkey).to eq("8832162")
    end
    
    it "should return nil for an identityMetadata without catkey" do
      identityMetadataXML = double(String)
      
      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_3)
      )
      
      d = Dor::Item.new 

      allow(d).to receive_messages(
        :datastreams => {"identityMetadata"=>identityMetadataXML} 
      )

      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.catkey).to be_nil
    end
  end

  describe ".object_type" do
    it "should return object_type from a valid identityMetadata" do
      identityMetadataXML = double(String)

      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_1)
      )

      d = Dor::Item.new

      allow(d).to receive_messages(
        :datastreams => {"identityMetadata"=>identityMetadataXML}
      )

      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.object_type).to eq("|xitem")
    end
    
    it "should return an empty x subfield for identityMetadata without object_type" do
      identityMetadataXML = double(String)

      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_3)
      )

      d = Dor::Item.new

      allow(d).to receive_messages(
        :datastreams => {"identityMetadata"=>identityMetadataXML}
      )

      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.object_type).to eq("|x")
    end
  end

  describe ".display_type" do
    it "should return display_type from valid identityMetadata" do
      identityMetadataXML = double(String)

      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_1)
      )

      d = Dor::Item.new

      allow(d).to receive_messages(
        :datastreams => {"identityMetadata"=>identityMetadataXML}
      )

      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.display_type).to eq("|ximage")
    end

    it "should return contentMetadata @type for display_type if identityMetadata doesn't have display_type" do
      identityMetadataXML = double(String)
      contentMetadataXML = double(String)

      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_3)
      )

      allow(contentMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_content_metadata_1)
      )

      d = Dor::Item.new

      allow(d).to receive_messages(
        :datastreams => {"identityMetadata"=>identityMetadataXML, "contentMetadata"=>contentMetadataXML}
      )

      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.display_type).to eq("|xmap")
    end

    it "should return display_type of citation if identityMetadata doesn't have display_type and contentMetadata doesn't have @type" do
      identityMetadataXML = double(String)
      contentMetadataXML = double(String)

      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_3)
      )

      allow(contentMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_content_metadata_2)
      )

      d = Dor::Item.new

      allow(d).to receive_messages(
        :datastreams => {"identityMetadata"=>identityMetadataXML, "contentMetadata"=>contentMetadataXML}
      )

      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.display_type).to eq("|xcitation")
    end
  end

  describe ".barcode" do
    it "should return barcode from a valid identityMetadata" do
      identityMetadataXML = double(String)

      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_1)
      )

      d = Dor::Item.new

      allow(d).to receive_messages(
        :datastreams => {"identityMetadata"=>identityMetadataXML}
      )

      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.barcode).to eq("|x36105216275185")
    end

    it "should return an empty x subfield for identityMetadata without barcode" do
      identityMetadataXML = double(String)
      
      allow(identityMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_identity_metadata_3)
      )
      
      d = Dor::Item.new 

      allow(d).to receive_messages(
        :datastreams => {"identityMetadata"=>identityMetadataXML} 
      )

      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.object_type).to eq("|x")
    end
  end

  describe ".file_ids" do
    it "should return file_ids from a valid contentMetadata" do
      contentMetadataXML = double(String)

      allow(contentMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_content_metadata_1)
      )

      d = Dor::Item.new

      allow(d).to receive_messages(
        :datastreams => {"contentMetadata"=>contentMetadataXML}
      )

      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.file_ids).to eq("|xwt183gy6220_00_0001.jp2")
    end

    it "should return an empty x subfield for contentMetadata without file_ids" do
      contentMetadataXML = double(String)

      allow(contentMetadataXML).to receive_messages(
        :ng_xml => Nokogiri::XML(build_content_metadata_3)
      )

      d = Dor::Item.new

      allow(d).to receive_messages(
        :datastreams => {"contentMetadata"=>contentMetadataXML}
      )

      updater = Dor::UpdateMarcRecordService.new(d)
      expect(updater.file_ids).to eq("|x")
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
      updater.instance_variable_set(:@druid_id,"aa111aa1111")
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
        :id => "cc111cc1111",
        :catkey => "12345678"
      )
      
      allow(item).to receive_messages(
        :id => "aa111aa1111",
        :collections =>[collection],
      )
      updater = Dor::UpdateMarcRecordService.new(item)
      expect(updater.get_x2_collection_info).to eq("|xcc111cc1111:12345678:Collection label")
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
  <objectType>collection</objectType>
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
  def build_identity_metadata_3
    identityMetadataXML = '<identityMetadata>
  <sourceId source="sul">36105216275185</sourceId>
  <objectId>druid:bb987ch8177</objectId>
  <objectCreator>DOR</objectCreator>
  <objectLabel>A  new map of Africa</objectLabel>
  <adminPolicy>druid:dd051ys2703</adminPolicy>
  <otherId name="uuid">ff3ce224-9ffb-11e3-aaf2-0050569b3c3c</otherId>
  <tag>Process : Content Type : Map</tag>
  <tag>Project : Batchelor Maps : Batch 1</tag>
  <tag>LAB : MAPS</tag>
  <tag>Registered By : dfuzzell</tag>
  <tag>Remediated By : 4.15.4</tag>
</identityMetadata>'
  end

  def build_content_metadata_1
    contentMetadataXML = '<contentMetadata objectId="wt183gy6220" type="map">
<resource id="wt183gy6220_1" sequence="1" type="image">
<label>Image 1</label>
<file id="wt183gy6220_00_0001.jp2" mimetype="image/jp2" size="3182927">
<imageData width="4531" height="3715"/>
</file>
</resource>
</contentMetadata>'
  end
  def build_content_metadata_2
    contentMetadataXML = '<contentMetadata objectId="wt183gy6220">
<resource id="wt183gy6220_1" sequence="1" type="image">
<label>Image 1</label>
<file id="wt183gy6220_00_0001.jp2" mimetype="image/jp2" size="3182927">
<imageData width="4531" height="3715"/>
</file>
</resource>
<resource id="wt183gy6220_2" sequence="2" type="image">
<label>Image 2</label>
<file id="wt183gy6220_00_0002.jp2" mimetype="image/jp2" size="3182927">
<imageData width="4531" height="3715"/>
</file>
</resource>
</contentMetadata>'
  end
    def build_content_metadata_3
    contentMetadataXML = '<contentMetadata objectId="wt183gy6220">
</contentMetadata>'
  end
end
