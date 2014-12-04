# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module ItemRelease   # This is your workflow package name (using CamelCase)

      class ReleaseMembers # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 
        
        def initialize
          super('dor', 'releaseWF', 'release-members', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "release-members working on #{druid}"
          
          item = Dor::ItemRelease::Item.new :druid => druid
                              
          if item.is_collection? || item.is_set? # this is a collection or set
            LyberCore::Log.debug "...fetching members of #{item.object_type}"
            if item.item_members # if there are any members, iterate through
              item.item_members.each do |member|
                member_druid=member['druid']
                add_workflow(member_druid)
              end
            else
              LyberCore::Log.debug "...no members found in #{item.object_type}"            
            end
          elsif item.is_apo?
            LyberCore::Log.debug "...this is an APO, noop"            
          else
            LyberCore::Log.debug "...not a collection or set or apo, noop"
          end
          
        end
        
        def add_workflow(druid)
          # TODO add retry logic here for adding workflow
          LyberCore::Log.debug "...adding itemReleaseWF for #{druid}"
          url         = "#{Dor::Config.dor.service_root}/objects/druid:#{druid}/apo_workflows/itemReleaseWF"
          resp=RestClient.post url, {}
        end
        
      end

    end
  end
end
