# encoding: utf-8
require "logstash/inputs/base"
require "stud/interval"
require "socket" # for Socket.gethostname
require 'java'
require_relative '../../org/apache/kafka/kafka-clients/2.3.0/kafka-clients-2.3.0.jar'
require_relative '../../org/slf4j/slf4j-api/1.7.26/slf4j-api-1.7.26.jar'
#require_relative 'lib\org\apache\kafka\kafka-clients\2.3.0\kafka-clients-2.3.0.jar'
#require_relative 'lib\org\slf4j\slf4j-api\1.7.26\slf4j-api-1.7.26.jar'
# Generate a repeating message.
#
# This plugin is intented only as an example.

class LogStash::Inputs::Test3 < LogStash::Inputs::Base


  config_name 'test3'

  default :codec, 'plain'

  config :bootstrap_servers, :validate => :string, :default => "localhost:9092"

  config :client_id, :validate => :string, :default => "fjpp"

  config :group_id, :validate => :string, :default => "fjpp"

  config :auto_offset_reset, :validate => :string, :default => "earliest"

  config :consumer_threads, :validate => :number, :default => 5

  config :max_poll_records, :validate => :string, :default => "3"

  config :topics, :validate => :string, :default => "audit"

  config :poll_timeout_ms, :validate => :number, :default => 100

  config :decorate_events, :validate => :boolean, :default => false

  public

  def register
    begin
      puts "register-----------begin"
      @runner_threads = []
    rescue Exception => e
      puts "register   ex"
      puts e.message
      raise e
    end
  end

  # def register

  public

  def run(logstash_queue)
    begin
      puts "run-----------begin"
      @runner_consumers = consumer_threads.times.map { |i| create_consumer("#{client_id}-#{i}") }
      @runner_threads = @runner_consumers.map { |consumer| thread_runner2(logstash_queue,consumer) }
      @runner_threads.each { |t| t.join }
    rescue Exception => e
      puts "run   ex"
      puts e.message
      raise e
    end
  end


  public

  def stop
    # if we have consumers, wake them up to unblock our runner threads
    @runner_consumers && @runner_consumers.each(&:wakeup)
  end


  public

  def thread_runner2(logstash_queue, consumer)
    puts "thread------runner-------------begin"
    Thread.new do
      begin
        pattern = java.util.regex.Pattern.compile(topics) ### 需要转换
        consumer.subscribe(pattern)
        while !stop?
          records = consumer.poll(poll_timeout_ms)
          codec_instance = @codec.clone
          next unless records.count > 0
          for record in records do
            codec_instance.decode(record.value.to_s) do |event|##从kafaka 中的值全部查出了变成字符串，然后编码器转成event
              decorate(event)
              if @decorate_events
                event.set("[@metadata][kafka][topic]", record.topic)
                event.set("[@metadata][kafka][consumer_group]", @group_id)
                event.set("[@metadata][kafka][partition]", record.partition)
                event.set("[@metadata][kafka][offset]", record.offset)
                event.set("[@metadata][kafka][key]", record.key)
                event.set("[@metadata][kafka][timestamp]", record.timestamp)
              end
              logstash_queue << event
              end
            end
          end
          rescue org.apache.kafka.common.errors.WakeupException => e
          raise e if !stop?
          ensure
          consumer.close
        end
      end
    end


    def create_consumer(client_id)
      #logger.info("create---------consumer------begin")
      begin
        props = java.util.Properties.new
        kafka = org.apache.kafka.clients.consumer.ConsumerConfig
        props.put(kafka::AUTO_OFFSET_RESET_CONFIG, auto_offset_reset) unless auto_offset_reset.nil?
        props.put(kafka::BOOTSTRAP_SERVERS_CONFIG, bootstrap_servers)
        props.put(kafka::CLIENT_ID_CONFIG, client_id)
        props.put(kafka::GROUP_ID_CONFIG, group_id)
        props.put(kafka::MAX_POLL_RECORDS_CONFIG, max_poll_records) unless max_poll_records.nil?
        props.put(kafka::KEY_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer")
        props.put(kafka::VALUE_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer")
        org.apache.kafka.clients.consumer.KafkaConsumer.new(props)
      rescue => e
        logger.error("Unable to create Kafka consumer from given configuration",
                     :kafka_error_message => e,
                     :cause => e.respond_to?(:getCause) ? e.getCause() : nil)
        raise e
      end
    end

  end
