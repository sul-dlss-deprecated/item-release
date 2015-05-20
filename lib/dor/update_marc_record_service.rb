require 'open3'

module Dor
  class UpdateMarcRecordService
    
    def initialize druid_obj
      @druid_obj = druid_obj
      @druid_id = @druid_obj.id.sub("druid:","")
    end

    def push_symphony_record
      symphony_record = generate_symphony_record
      write_symphony_record symphony_record
    end
    def generate_symphony_record

      if catkey.nil? || catkey.length == 0 then
        return ""
      end
      
      purl_uri = get_u_field
      collection_info = get_x2_collection_info

      # catkey: the catalog key that associates a DOR object with a specific Symphony record.
      # .856. 41
      # Subfield u (required): the full Purl URL
      # Subfield x #1 (required): The string SDR-PURL as a marker to identify 856 entries managed through DOR
      # Subfield x #2 (required): Object type (<identityMetadata><objectType>) – item, collection, 
      #     (future types of sets to describe other aggregations like albums, atlases, etc)
      # Subfield x #3 (required): The display type of the object.
      #     use an explicit display type from the object if present (<identityMetadata><displayType>)
      #     else use the value of the <contentMetadata> "type" attribute if present, e.g., image, book, file
      #     else use the value “citation"
      # Subfield x #4 (required): the barcode if known (<identityMetadata><otherId name="barcode">, else null
      # Subfield x #5 (required): the file-id to be used as thumb if available, else null
      # Subfield x #6..n (optional): Collection(s) this object is a member of, recorded as druid-value:ckey-value:title

      return "#{catkey}\t#{get_856_cons} #{get_1st_indicator}#{get_2nd_indicator}#{purl_uri}#{get_x1_sdrpurl_marker}#{object_type}#{display_type}#{barcode}#{file_ids}#{collection_info}"
    end
    
    def write_symphony_record symphony_record
      if symphony_record.nil? || symphony_record.length == 0 then
        return
      end
      symphony_file_name = "#{Dor::Config.release.symphony_path}/sdr-purl-#{@druid_id}-#{Time.now.strftime('%Y%m%d%H%M%S')}"
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

    # @return [String] value with SIRSI/Symphony numeric catkey in it, or nil if none exists
    # look in identityMetadata/otherId[@name='catkey']
    def catkey object
      @catkey ||= begin
        catkey = nil
        node = object.identity_md.at_xpath("//identityMetadata/otherId[@name='catkey']")
        catkey = node.content if node
        catkey
      end
    end

    # @return [String] value with object_type in it, or empty x subfield if none exists
    # look in identityMetadata/objectType
    def object_type
      @objectType ||= begin
        objectType = ''
        node = identity_md.at_xpath("//identityMetadata/objectType")
        objectType = node.content if node
        objectType.prepend("|x")
      end
    end

    # value is used to tell SearchWorks UI app of specific display needs for objects
    # @return [String] identityMetadata displayType, DOR content type, or citation in an x subfield
    def display_type
      @displayType ||= begin
        displayType = ''
        if node = identity_md.at_xpath("//identityMetadata/displayType")
          displayType = node.content
        elsif node = content_md.at_xpath("//contentMetadata/@type")
          displayType = node.content
        else
          if object_type != "|xcollection"
            displayType = "citation"
          end
        end
        displayType.prepend("|x")
      end
    end

    # @return [String] value with barcode in it, or empty x subfield if none exists
    # look in identityMetadata/otherId name="barcode"
    def barcode
      @barcode ||= begin
        barcode = ''
        node = identity_md.at_xpath("//identityMetadata/otherId[@name='barcode']")
        barcode = node.content if node
        barcode.prepend("|x")
      end
    end

    # the @id attribute of resource/file elements that match the display_type, including extension
    # @return [String] filenames separated by comma
    def file_ids
      ids = []
      if content_md
        content_md.xpath('//contentMetadata/resource/file').each { |node|
          ids << node.attr("id") if !node.nil?
        }
      end
      ids.join(',').prepend("|x")
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
      return "|u#{Dor::Config.release.purl_base_uri}/#{@druid_id}"
    end

    # It returns the SDR-PURL subfield
    def get_x1_sdrpurl_marker
      return "|xSDR-PURL"
    end

    # It returns the collection information subfields if exists
    # @return [String] the colleciton information druid-value:catkey-value:title format
    def get_x2_collection_info 
      collections = @druid_obj.collections
      coll_info = ""

      if collections.length > 0 then
        collections.each { |coll|
          coll_info += "|x#{coll.id}:#{catkey(coll)}:#{coll.label}"
        }
      end

      coll_info
    end

    # the identityMetadata for this object 
    # @return [Nokogiri::XML::Element] containing the identityMetadata
    def identity_md
      @identity_md ||= @druid_obj.datastreams["identityMetadata"].ng_xml
    end

    # the contentMetadata for this object
    # @return [Nokogiri::XML::Element] containing the contentMetadata
    def content_md 
      @content_md ||= @druid_obj.datastreams["contentMetadata"].ng_xml
    end
  end
end
