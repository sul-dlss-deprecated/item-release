require "retries"

module Dor::Release

  class Item
  
    def initialize(params = {})
      # Takes a druid, either as a string or as a Druid object.
      @druid = params[:druid]
      @fetcher = DorFetcher::Client.new({:service_url => Dor::Config.release.fetcher_root})
    end

    def object
      @fobj ||= Dor::Item.find(@druid)
    end    
    
    def members 
      unless @members # if members have not been fetched and cached for this object yet, fetch them

        handler = Proc.new do |exception, attempt_number, total_delay|
          LyberCore::Log.debug "#{exception.class} on dor-fetcher-service get members call #{attempt_number} for #{@druid}"
        end
      
        with_retries(:max_tries => Dor::Config.release.max_tries, :handler => handler, :base_sleep_seconds => Dor::Config.release.base_sleep_seconds, :max_sleep_seconds => Dor::Config.release.max_sleep_seconds) do |attempt|
           @members=@fetcher.get_collection(@druid)  # cache members in an instance variable
        end
        
      else
        
        @members # return cached instance variable
      
      end
    end
    
    def item_members
      members['items']
    end
    
    def sub_collections
      unless @sub_collections
        @sub_collections=[]
        @sub_collections += members['sets'] if members['sets']
        @sub_collections += members['collections'] if members['collections']  
      end
      @sub_collections
    end
    
    def object_type
      unless @obj_type
        obj_type=object.identityMetadata.objectType
        @obj_type=(obj_type.nil? ? 'unknown' : obj_type.first)
      end
      @obj_type.downcase.strip
    end
    
    def republish_needed?
      #TODO implement logic here, presumably by calling a method on dor-services-gem
      false
      
      #LyberCore::Log.debug "republishing metadatra for #{@druid}"
      
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

    def self.add_workflow_for_collection(druid)
      self.create_workflow(druid)
    end

    def self.add_workflow_for_item(druid)
      self.create_workflow(druid)
      self.set_release_to_completed(druid)
    end
    
    def self.create_workflow(druid)
    
      handler = Proc.new do |exception, attempt_number, total_delay|
        LyberCore::Log.debug "#{exception.class} on initialize workflow attempt #{attempt_number} for #{druid}"
      end
        
      LyberCore::Log.debug "...adding workflow #{Dor::Config.release.workflow_name} for #{druid}"
      
      # initiate workflow
      with_retries(:max_tries => Dor::Config.release.max_tries, :handler => handler, :base_sleep_seconds => Dor::Config.release.base_sleep_seconds, :max_sleep_seconds => Dor::Config.release.max_sleep_seconds) do |attempt|
        obj=Dor::Item.find(druid)
        obj.initialize_workflow(Dor::Config.release.workflow_name)
      end

    end

    def self.set_release_to_completed(druid)
    
      handler = Proc.new do |exception, attempt_number, total_delay|
        LyberCore::Log.debug "#{exception.class} on workflow service attempt #{attempt_number} for #{druid}"
      end
        
      LyberCore::Log.debug "...setting release to completed in #{Dor::Config.release.workflow_name} for #{druid}"
      
      # set release-members step to completed
      with_retries(:max_tries => Dor::Config.release.max_tries, :handler => handler, :base_sleep_seconds => Dor::Config.release.base_sleep_seconds, :max_sleep_seconds => Dor::Config.release.max_sleep_seconds) do |attempt|
        Dor::WorkflowService.update_workflow_status 'dor', druid, Dor::Config.release.workflow_name, 'release-members', 'completed'
      end

    end
            
  end  # class Item
end # module