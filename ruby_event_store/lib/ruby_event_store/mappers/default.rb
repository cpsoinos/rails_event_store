require 'yaml'

module RubyEventStore
  module Mappers
    class Default < PipelineMapper
      def initialize(serializer: YAML, events_class_remapping: {})
        super(Pipeline.new(
          transformations: [
            EventClassRemapper.new(events_class_remapping),
            SymbolizeMetadataKeys.new,
            SerializationMapper.new(serializer: serializer),
          ]
        ))
      end
    end
  end
end
