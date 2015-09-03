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

      druid_ckey = ckey @druid_obj
      return "" unless druid_ckey.present?

      if released_to_Searchworks
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
        # Subfield x #4 (optional): the barcode if known (<identityMetadata><otherId name="barcode">, recorded as barcode:barcode-value
        # Subfield x #5 (optional): the file-id to be used as thumb if available, recorded as file:file-id-value
        # Subfield x #6..n (optional): Collection(s) this object is a member of, recorded as collection:druid-value:ckey-value:title

        new856 = "#{druid_ckey}\t#{get_856_cons} #{get_1st_indicator}#{get_2nd_indicator}#{purl_uri}#{get_x1_sdrpurl_marker}#{object_type}#{display_type}"
        new856 << barcode unless barcode.nil?
        new856 << file_id unless file_id.nil?
        new856 << collection_info unless collection_info.nil?
        new856
      else
        "#{druid_ckey}\t"
      end
    end

    def write_symphony_record symphony_record
      if symphony_record.nil? || symphony_record.length == 0 then
        return
      end
      symphony_file_name = "#{Dor::Config.release.symphony_path}/sdr-purl-856s"
      command = "#{Dor::Config.release.write_marc_script} \'#{symphony_record}\' #{symphony_file_name}"
      run_write_script(command)
    end

    def run_write_script(command)
      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        stdout_text = stdout.read
        stderr_text = stderr.read

        if stdout_text.length > 0 || stderr_text.length > 0 then
          raise "Error in writing marc_record file using the command #{command}\n#{stdout_text}\n#{stderr_text}"
        end
      end
    end

    # @return [String] value with SIRSI/Symphony numeric catkey in it, or nil if none exists
    # look in identityMetadata/otherId[@name='catkey']
    def ckey object
      unless object.datastreams.nil? || object.datastreams["identityMetadata"].nil?
        if object.datastreams["identityMetadata"].ng_xml
          node = object.identityMetadata.ng_xml.at_xpath("//identityMetadata/otherId[@name='catkey']")
        end
      end
      node.content if node && node.content.present?
    end

    # @return [String] value with object_type in it, or empty x subfield if none exists
    # look in identityMetadata/objectType
    def object_type
      @object_type ||= begin
        objectType = ''
        node = @druid_obj.datastreams["identityMetadata"].ng_xml.at_xpath("//identityMetadata/objectType")
        objectType = node.content if !node.nil?
        objectType.prepend("|x")
      end
    end

    # value is used to tell SearchWorks UI app of specific display needs for objects
    # @return [String] identityMetadata displayType, DOR content type, or citation in an x subfield
    def display_type
      @display_type ||= begin
        displayType = ''
        if node = @druid_obj.datastreams["identityMetadata"].ng_xml.at_xpath("//identityMetadata/displayType")
          displayType = node.content
        elsif node = @druid_obj.datastreams["contentMetadata"].ng_xml.at_xpath("//contentMetadata/@type")
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
        barcode = nil
        node = @druid_obj.datastreams["identityMetadata"].ng_xml.at_xpath("//identityMetadata/otherId[@name='barcode']")
        barcode = node.content.prepend("|xbarcode:") if !node.nil?
      end
    end

    # the @id attribute of resource/file elements that match the display_type, including extension
    # @return [String] first filename
    def file_id
      id = nil
      unless @druid_obj.datastreams.nil? || @druid_obj.datastreams["contentMetadata"].nil? then
        if @druid_obj.datastreams["contentMetadata"].ng_xml then
          node = @druid_obj.datastreams["contentMetadata"].ng_xml.xpath('//contentMetadata/resource/file').first
          id = node.attr("id").prepend("|xfile:") if !node.nil?
        end
      end
      id = id.split(/\./).first if !id.nil?
      id
    end

    # It returns 856 constants
    def get_856_cons
      ".856."
    end

    # It returns First Indicator for HTTP (4)
    def get_1st_indicator
      "4"
    end

    # It returns Second Indicator for Version of resource (1)
    def get_2nd_indicator
      "1"
    end

    # It's a plceholder for the uri label
    def get_z_field
      #  Placeholder to be used in the future
    end

    # It builds the PURL uri based on the druid id
    def get_u_field
      "|u#{Dor::Config.release.purl_base_uri}/#{@druid_id}"
    end

    # It returns the SDR-PURL subfield
    def get_x1_sdrpurl_marker
      "|xSDR-PURL"
    end

    # It returns the collection information subfields if exists
    # @return [String] the collection information druid-value:catkey-value:title format
    def get_x2_collection_info
      collections = @druid_obj.collections
      coll_info = ""

      if collections.length > 0 then
        collections.each { |coll|
          coll_info << "|xcollection:#{coll.id.sub("druid:","")}:#{ckey(coll)}:#{coll.label}"
        }
      end

      coll_info
    end

    def released_to_Searchworks
      node = @druid_obj.identityMetadata.ng_xml.at_xpath("//identityMetadata/release[@to='Searchworks']")
      node && node.content == 'true'
    end

  end
end
