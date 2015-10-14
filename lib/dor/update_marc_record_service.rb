require 'open3'

module Dor
  class UpdateMarcRecordService
    def initialize(druid_obj)
      @druid_obj = druid_obj
      @druid_id = @druid_obj.id.sub('druid:', '')
    end

    def push_symphony_record
      symphony_record = generate_symphony_record
      write_symphony_record symphony_record
    end

    def generate_symphony_record
      druid_ckey = ckey @druid_obj
      return '' unless druid_ckey.present?

      if released_to_Searchworks
        purl_uri = get_u_field
        collection_info = get_x2_collection_info

        # catkey: the catalog key that associates a DOR object with a specific Symphony record.
        # druid: the druid
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

        new856 = "#{druid_ckey}\t#{@druid_id}\t#{get_856_cons} #{get_1st_indicator}#{get_2nd_indicator}#{purl_uri}#{get_x1_sdrpurl_marker}#{object_type}#{display_type}"
        new856 << barcode unless barcode.nil?
        new856 << file_id unless file_id.nil?
        new856 << collection_info unless collection_info.nil?
        new856
      else
        "#{druid_ckey}\t#{@druid_id}\t"
      end
    end

    def write_symphony_record(symphony_record)
      return if symphony_record.nil? || symphony_record.length == 0
      symphony_file_name = "#{Dor::Config.release.symphony_path}/sdr-purl-856s"
      command = "#{Dor::Config.release.write_marc_script} \'#{symphony_record}\' #{symphony_file_name}"
      run_write_script(command)
    end

    def run_write_script(command)
      Open3.popen3(command) do |_stdin, stdout, stderr, _wait_thr|
        stdout_text = stdout.read
        stderr_text = stderr.read

        if stdout_text.length > 0 || stderr_text.length > 0
          fail "Error in writing marc_record file using the command #{command}\n#{stdout_text}\n#{stderr_text}"
        end
      end
    end

    # @return [String] value with SIRSI/Symphony numeric catkey in it, or nil if none exists
    # look in identityMetadata/otherId[@name='catkey']
    def ckey(object)
      unless object.datastreams.nil? || object.datastreams['identityMetadata'].nil?
        if object.datastreams['identityMetadata'].ng_xml
          node = object.identityMetadata.ng_xml.at_xpath("//identityMetadata/otherId[@name='catkey']")
        end
      end
      node.content if node && node.content.present?
    end

    # @return [String] value with object_type in it, or empty x subfield if none exists
    # look in identityMetadata/objectType
    def object_type
      @object_type ||= begin
        object_type = ''
        node = @druid_obj.datastreams['identityMetadata'].ng_xml.at_xpath('//identityMetadata/objectType')
        object_type = node.content unless node.nil?
        object_type.prepend('|x')
      end
    end

    # value is used to tell SearchWorks UI app of specific display needs for objects
    # @return [String] identityMetadata displayType, DOR content type, or citation in an x subfield
    def display_type
      @display_type ||= begin
        display_type = ''
        if node = @druid_obj.datastreams['identityMetadata'].ng_xml.at_xpath('//identityMetadata/displayType')
          display_type = node.content
        elsif node = @druid_obj.datastreams['contentMetadata'].ng_xml.at_xpath('//contentMetadata/@type')
          display_type = node.content
        else
          display_type = 'citation' if object_type != '|xcollection'
        end
        display_type.prepend('|x')
      end
    end

    # @return [String] value with barcode in it, or empty x subfield if none exists
    # look in identityMetadata/otherId name="barcode"
    def barcode
      @barcode ||= begin
        node = @druid_obj.datastreams['identityMetadata'].ng_xml.at_xpath("//identityMetadata/otherId[@name='barcode']")
        node.content.prepend('|xbarcode:') unless node.nil?
      end
    end

    # the @id attribute of resource/file elements that match the display_type, including extension
    # @return [String] first filename
    def file_id
      id = nil
      filename = nil
      unless @druid_obj.datastreams.nil? || @druid_obj.datastreams['contentMetadata'].nil?
        if @druid_obj.datastreams['contentMetadata'].ng_xml
          resources = @druid_obj.datastreams['contentMetadata'].ng_xml.xpath('//contentMetadata/resource')
          resources.detect do |res|
            children = res.children if res.attr('type') == 'image' || res.attr('type') == 'page'
            children.detect do |child|
              filename = child.attr('id') if child.attr('mimetype') == 'image/jp2'
            end
          end
          id = filename.prepend('|xfile:') unless filename.nil?
        end
      end
      id = id.split(/\./).first unless id.nil?
      id
    end

    # It returns 856 constants
    def get_856_cons
      '.856.'
    end

    # It returns First Indicator for HTTP (4)
    def get_1st_indicator
      '4'
    end

    # It returns Second Indicator for Version of resource (1)
    def get_2nd_indicator
      '1'
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
      '|xSDR-PURL'
    end

    # It returns the collection information subfields if exists
    # @return [String] the collection information druid-value:catkey-value:title format
    def get_x2_collection_info
      collections = @druid_obj.collections
      coll_info = ''

      if collections.length > 0
        collections.each do |coll|
          coll_info << "|xcollection:#{coll.id.sub('druid:', '')}:#{ckey(coll)}:#{coll.label}"
        end
      end

      coll_info
    end

    def released_to_Searchworks
      rel = @druid_obj.released_for
      rel['Searchworks']['release']
    end
  end
end
