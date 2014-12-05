require "retries"

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
      unless @members # if members have not been fetched and cached for this object yet, fetch them

        handler = Proc.new do |exception, attempt_number, total_delay|
          LyberCore::Log.debug "#{exception.class} on dor-fetcher-service get members call #{attempt_number} for #{@druid}"
        end
      
        with_retries(:max_tries => Dor::Config.itemRelease.max_tries, :handler => handler, :base_sleep_seconds => Dor::Config.itemRelease.base_sleep_seconds, :max_sleep_seconds => Dor::Config.itemRelease.max_sleep_seconds) do |attempt|
           @members=@fetcher.get_collection(@druid)  # cache members in an instance variable
        end
        
      else
        
        @members # return cached instance variable
      
      end
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
    
      handler = Proc.new do |exception, attempt_number, total_delay|
        LyberCore::Log.debug "#{exception.class} on workflow service attempt #{attempt_number} for #{druid} to #{url}"
      end
        
      LyberCore::Log.debug "...adding workflow #{Dor::Config.itemRelease.workflow_name} for #{druid}"
      
      # initiate workflow and set release-members step to completed
      with_retries(:max_tries => Dor::Config.itemRelease.max_tries, :handler => handler, :base_sleep_seconds => Dor::Config.itemRelease.base_sleep_seconds, :max_sleep_seconds => Dor::Config.itemRelease.max_sleep_seconds) do |attempt|
        @fobj.initialize_workflow(Dor::Config.itemRelease.workflow_name)
        Dor::WorkflowService.update_workflow_status 'dor', druid, Dor::Config.itemRelease.workflow_name, 'release-members', 'completed'
      end

    end
        
  end  # class Item
end # module