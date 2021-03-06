module RubyEventStore
  module Mappers
    class Pipeline
      def initialize(to_domain_event: DomainEventMapper.new,
                     to_serialized_record: SerializedRecordMapper.new,
                     transformations: nil)
        @transformations = [
          to_domain_event,
          Array(transformations),
          to_serialized_record
        ].flatten.freeze
      end

      def dump(domain_event)
        transformations.reduce(domain_event) do |item, transform|
          transform.dump(item)
        end
      end

      def load(record)
        transformations.reverse.reduce(record) do |item, transform|
          transform.load(item)
        end
      end

      attr_reader :transformations
    end
  end
end
