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
      @obj_type.downcase.strip
    end
    
    def is_item?
      object_type == 'item'
    end
    
    def is_collection?
      object_type == 'collection'
    end

    def is_set?
      object_type == 'set'
    end

    def is_apo?
      object_type == 'adminPolicy'
    end

    def self.add_workflow_for_item(druid)
      
      # TODO add retry logic here for adding workflow
      LyberCore::Log.debug "...adding workflow #{Dor::Config.itemRelease.workflow_name} for #{druid}"
      url         = "#{Dor::Config.dor.service_root}/objects/druid:#{druid}/workflows/#{Dor::Config.itemRelease.workflow_name}"
      resp=RestClient.post url, {}

      # set release-members step to completed
      url         = "#{Dor::Config.dor.service_root}/objects/druid:#{druid}/workflows/#{Dor::Config.itemRelease.workflow_name}/release-members/completed"
      resp=RestClient.post url, {}

    end

  end  
end