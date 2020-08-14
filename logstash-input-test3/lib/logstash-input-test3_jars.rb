# this is a generated file, to avoid over-writing it just delete this comment
begin
  require 'jar_dependencies'
rescue LoadError
  require 'com/github/luben/zstd-jni/1.4.0-1/zstd-jni-1.4.0-1.jar'
  require 'org/xerial/snappy/snappy-java/1.1.7.3/snappy-java-1.1.7.3.jar'
  require 'org/apache/kafka/kafka-clients/2.3.0/kafka-clients-2.3.0.jar'
  require 'org/slf4j/slf4j-api/1.7.26/slf4j-api-1.7.26.jar'
  require 'org/lz4/lz4-java/1.6.0/lz4-java-1.6.0.jar'
end

if defined? Jars
  require_jar 'com.github.luben', 'zstd-jni', '1.4.0-1'
  require_jar 'org.xerial.snappy', 'snappy-java', '1.1.7.3'
  require_jar 'org.apache.kafka', 'kafka-clients', '2.3.0'
  require_jar 'org.slf4j', 'slf4j-api', '1.7.26'
  require_jar 'org.lz4', 'lz4-java', '1.6.0'
end
