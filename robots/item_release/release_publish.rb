# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module ItemRelease   # This is your workflow package name (using CamelCase)

      class ReleasePublish # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', Dor::Config.itemRelease.workflow_name, 'release-publish', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)

          LyberCore::Log.debug "release-publish working on #{druid}"

          item = Dor::ItemRelease::Item.new :druid => druid

          # TODO Check item's collections tags here or in Dor::Item?
          
#          collections=item.collections            # gives an array of fedora collection objects for this item

#          item.tags                    # gives us an array of tags
#          item.add_tag("Key: Value")   # adds a new tag
#          item.save                    # saves the item

          # TODO define the republish_needed? method on Dor::Item
          item.object.publish_metadata if item.republish_needed?
                      
        end
      end

    end
  end
end
