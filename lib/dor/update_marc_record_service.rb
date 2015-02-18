require 'open3'

module Dor
  class UpdateMarcRecordService
    
    def initialize druid_obj
      @druid_obj = druid_obj
      @druid_id = @druid_obj.id
    end

    def push_symphony_record
      symphony_record = generate_symphony_record
      write_symphony_record symphony_record
    end
    def generate_symphony_record
      catkey = get_ckey @druid_obj.datastreams["identityMetadata"].ng_xml
      
      if catkey.nil? || catkey.length == 0 then
        return ""
      end
      
      purl_uri = get_u_field
      collection_info = get_x2_collection_info
      
      return "#{catkey}\t#{get_856_cons} #{get_1st_indicator}#{get_2nd_indicator}#{purl_uri}#{get_x1_sdrpurl_marker}#{collection_info}"
    end
    
    def write_symphony_record symphony_record
      if symphony_record.nil? || symphony_record.length == 0 then
        return
      end
      symphony_file_name = "#{Dor::Config.release.symphony_path}/sdr-purl-#{@druid_id.sub("druid:","")}-#{Time.now.strftime('%Y%m%d%H%M%S')}"
      command = "#{Dor::Config.release.write_marc_script} '#{symphony_record}' #{symphony_file_name}"
      run_write_script(command)
    end

    def run_write_script(command)
      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        stdout_text = stdout.read
        stderr_text = stderr.read
        
        if stdout_text.length > 0 || stderr_text.length > 0 then
          raise "There was an error in writting marc_record file using the command #{command}\n#{stdout_text}\n#{stderr_text}"
        end
      end    
    end
    # It extracts catkey from the druid object identityMetadataXML
    # @param [nokogiri_xml_object] identityMetadataXML -- identityMetadataStream XML for the druid
    # @return [String] the catkey of the druid object.
    def get_ckey identityMetadataXML
      xpath_results = identityMetadataXML.at_xpath('//identityMetadata/otherId[@name="catkey"]')
      unless  xpath_results.nil? then
        return xpath_results.content
      else 
        return nil
      end
    end

    # It returns 856 constants
    def get_856_cons
      return ".856."
    end
    
    # It returns First Indicator for HTTP (4)
    def get_1st_indicator
      return "4" 
    end
    
    # It returns Second Indicator for Version of resource (1)
    def get_2nd_indicator
      return "1"
    end
    
    # It's a plceholder for the uri label 
    def get_z_field
      #  Placeholder to be used in the future
    end
    
    # It builds the PURL uri based on the druid id
    def get_u_field 
      return "|u#{Dor::Config.release.purl_base_uri}/#{@druid_id.sub("druid:","")}"
    end

    # It returns the SDR-PURL subfield
    def get_x1_sdrpurl_marker
      return "|xSDR-PURL"
    end

    # It returns the collection information subfields if exists
    # @return [String] the colleciton information druid:value:title format
    def get_x2_collection_info 
      collections = @druid_obj.collections

      if collections.length > 0 then
        collection_title = collections[0].label
        colleciton_id = collections[0].id
        return "|x#{colleciton_id}:#{collection_title}"
      else
        return ""
      end
    end
  end
end