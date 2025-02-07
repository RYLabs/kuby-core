# typed: strict

require 'time'

module Kuby
  module Docker
    class TimestampTag
      extend T::Sig

      FORMAT = T.let('%Y%m%d%H%M%S'.freeze, String)

      sig { params(str: T.nilable(String)).returns(T.nilable(TimestampTag)) }
      def self.try_parse(str)
        return nil unless str

        # The strptime function stops scanning after the pattern has been matched, so
        # we check for all numbers here to prevent things like 20210424165405-assets
        # from being treated as a timestamp tag.
        return nil unless str =~ /\A\d+\z/

        time = begin
          Time.strptime(str, FORMAT)
        rescue ArgumentError
          return nil
        end

        new(time)
      end

      sig { returns(TimestampTag) }
      def self.now
        new(Time.now.utc)
      end

      sig { returns(Time) }
      attr_reader :time

      sig { params(time: Time).void }
      def initialize(time)
        @time = T.let(time, Time)
      end

      sig { returns(String) }
      def to_s
        time.strftime(FORMAT)
      end

      sig { params(other: TimestampTag).returns(T.nilable(Integer)) }
      def <=>(other)
        time <=> other.time
      end

      sig { params(other: TimestampTag).returns(T::Boolean) }
      def ==(other)
        time == other.time
      end

      sig { returns(Integer) }
      def hash
        time.hash
      end

      sig { params(other: TimestampTag).returns(T::Boolean) }
      def eql?(other)
        time == other.time
      end
    end
  end
end
