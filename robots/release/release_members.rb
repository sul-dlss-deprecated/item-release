# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module Release   # This is your workflow package name (using CamelCase)

      class ReleaseMembers # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 
        
        def initialize
          super('dor', Dor::Config.release.workflow_name, 'release-members', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)

          handler = Proc.new do |exception, attempt_number, total_delay|
            LyberCore::Log.debug "#{exception.class} on dor-workflow-service call #{attempt_number} for #{@druid}" if attempt_number >= Dor::Config.release.max_tries
          end

          LyberCore::Log.debug "release-members working on #{druid}"
          
          item = Dor::Release::Item.new :druid => druid
          
          case item.object_type
            
            when "collection","set"  # this is a collection or set, initialize workflow for all item members and sub-collections                  
            
              LyberCore::Log.debug "...fetching members of #{item.object_type}"
              if item.item_members # if there are any members, iterate through and add item workflows (which includes setting the first step to completed)
            
                item.item_members.each do |item_member| 
                  with_retries(:max_tries => Dor::Config.release.max_tries, :handler => handler, :base_sleep_seconds => Dor::Config.release.base_sleep_seconds, :max_sleep_seconds => Dor::Config.release.max_sleep_seconds) do |attempt|
                    Dor::Release::Item.add_workflow_for_item(item_member['druid'])
                  end
                end
            
              elsif item.sub_collections # if there are any sub-collections, iterate through and add collection workflows

                  item.sub_collections.each do |sub_collection| 
                    with_retries(:max_tries => Dor::Config.release.max_tries, :handler => handler, :base_sleep_seconds => Dor::Config.release.base_sleep_seconds, :max_sleep_seconds => Dor::Config.release.max_sleep_seconds) do |attempt|
                      Dor::Release::Item.add_workflow_for_collection(sub_collection['druid'])
                    end
                  end
            
              else # no members found
            
                LyberCore::Log.debug "...no members found in #{item.object_type}"            
            
              end # end check for any members
            
            else # this is not a collection of set
            
              LyberCore::Log.debug "...this is a #{item.object_type}, NOOP"            
            
            end # end case statement
          
        end # end peform method 
         
      end # end releaseMembers class
                
    end
  end
end
