# encoding: utf-8
require_relative "../spec_helper"
require "gelf"

describe LogStash::Outputs::Gelf do

  let(:host) { "localhost" }
  let(:port) { rand(1024..65535) }

  it "should register without errors" do
    plugin = LogStash::Plugin.lookup("output", "gelf").new("host" => host, "port" => port)
    expect { plugin.register }.to_not raise_error
  end

  let(:message) { "This is a message!" }

  let(:event_base) {
    {
      "message" => message,
      "level" => "info",
      "test" => "logstash",
      "tags" => ["foo","bar"],
    }
  }
  let(:event_check) {
    {
      "message" => message,
      "level" => 3,
      "tags" => ["_grokparsefailure"],
    }
  }


  describe "#send event base" do

    subject { LogStash::Outputs::Gelf.new("host" => host, "port" => port ) }
    let (:timestamp)
    let(:event)      { LogStash::Event.new(event_base) }
    let(:gelf)       { GELF::Notifier.new(host, port, subject.chunksize) }

    before(:each) do
      subject.inject_client(gelf)
      subject.register
    end

    it "sends the generated event to gelf" do
      expect(subject.gelf).to receive(:notify!).with(hash_including("short_message"=> message,
                                                                    "full_message"=> message,
                                                                    "level"=> 6,
                                                                    "_test"=> "logstash",
                                                                    "_tags"=> ["foo","bar"]),
                                                     hash_including(:timestamp))
      subject.receive(event)
    end
  end

  describe "#send event check" do

    subject { LogStash::Outputs::Gelf.new("host" => host, "port" => port ) }
    let (:timestamp)
    let(:event)      { LogStash::Event.new(event_base) }
    let(:gelf)       { GELF::Notifier.new(host, port, subject.chunksize) }

    before(:each) do
      subject.inject_client(gelf)
      subject.register
    end

    it "sends the generated event to gelf" do
      expect(subject.gelf).to receive(:notify!).with(hash_including("short_message"=> message,
                                                                    "full_message"=> message,
                                                                     "level"=> 3,
                                                                    "_tags"=> "_grokparsefailure"),
                                                     hash_including(:timestamp))
      subject.receive(event)
    end
  end

end
