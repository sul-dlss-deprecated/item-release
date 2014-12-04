module Dor::ItemRelease

  class Item
  
    def initialize(params = {})
      # Takes a druid, either as a string or as a Druid object.
      @druid = params[:druid]
      @fetcher = DorFetcher::Client.new({:service_url => Dor::Config.itemRelease.fetcher_root})
    end

    def object
      @fobj ||= Dor::Item.find(@druid)
    end    
    
    def members 
      # TODO add retry logic here for getting collection members
      @members || @fetcher.get_collection(@druid)  
    end
    
    def item_members
      members['items']
    end
    
    def object_type
      unless @obj_type
        obj_type=object.identityMetadata.objectType
        @obj_type=(obj_type.nil? ? 'unknown' : obj_type.first)
      end
      @obj_type
    end
    
    def is_item?
      object_type.strip == 'item'
    end
    
    def is_collection?
      object_type.strip == 'collection'
    end

    def is_set?
      object_type.strip == 'set'
    end

    def is_apo?
      object_type.strip == 'adminPolicy'
    end

  end  
end