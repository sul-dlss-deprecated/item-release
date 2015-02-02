module Dor
  class UpdateMarcRecordService
    
    def initalize
    end

    def generate_symphony_record
    end
    
    def write_symphony_record
    end
        
    def get_ckey #identityMetadataStream
      # It reads the value form identityMetadata otherkeys 
    end

    def get_856_cons
      # it is a constant
      return "856"
    end

    def get_1st_indicator
      return "1" 
    end

    def get_2nd_indicator
      # ??
    end

    def get_z_field
      # ??
    end

    def get_u_field #druid_id
      # It builds it based on purl URI constant. + druid + .xml
    end

    def get_x1_sdrpurl_marker
      return "|xSDR-PURL"
    end

    def get_x2_format_type
      # ??
    end

    def get_x3_collection_info #druid_obj
      # It can extracts collection druid if exsits adn then format the collection info subfields based on
      # collection is member of
      # collection label from collection_object identityMetadata
      # druid:aa111aa1111:collectionlabel
    end
  end
end