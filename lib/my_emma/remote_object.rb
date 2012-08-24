require 'httparty'
require 'rubygems'
require 'crack'

module MyEmma


  class RemoteObject
    include HTTParty

    parser(
    ::Proc.new do |body, format|
      ::Crack::JSON.parse(body)
    end
    )

    def initialize(attr)
      attr.each do |key,val|
        check_key = key.to_sym
        if self.class::API_ATTRIBUTES.include?(check_key) then
          singleton_class.class_eval do; attr_reader "#{key}"; end
          if self.class::API_ACCESSIBLE.include?(check_key) then
            singleton_class.class_eval do; attr_reader "#{key}"; end
          end
          self.instance_variable_set "@#{key}", val
        end
      end

    end


    def self.set_http_values
      if base_uri.nil?
        base_uri MyEmma.base_uri
        basic_auth MyEmma.username, MyEmma.password
      end
    end

    def id
      nil
    end


    protected

    def persisted?
      return !self.id.nil?
    end

    def operation_ok?(response)
      [200,404].include?(response.code)
    end


  end
end
