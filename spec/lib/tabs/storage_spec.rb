require "spec_helper"

describe Tabs::Storage do
  context "#redis" do
    it "should return the configured Redis" do
      expect(subject.redis).to eq(Tabs::Config.redis)
    end
  end

  context "#tabs_key" do
    after do
      Tabs::Config.prefix = nil
    end

    it "should add prefix if configued" do
      Tabs::Config.prefix = "myapp"
      expect(subject.tabs_key("key")).to eq("tabs:myapp:key")
    end

    it "should not add prefix if not there" do
      expect(subject.tabs_key("key")).to eq("tabs:key")
    end
  end

  context "with stubbed redis" do

    let(:stubbed_redis) { double("redis").as_null_object }

    before do
      allow(subject).to receive(:redis).and_return(stubbed_redis)
      expect(subject).to receive(:tabs_key).at_least(:once).and_call_original
    end

    it "#exists calls exists with the expected key" do
      subject.exists("foo")
      expect(stubbed_redis).to have_received(:exists).with("tabs:foo")
    end

    it "#expireat calls expireat with expected key and timestamp" do
      subject.expireat("foo", 1234)
      expect(stubbed_redis).to have_received(:expireat).with("tabs:foo", 1234)
    end

    it "#ttl calls ttl with expected key" do
      subject.ttl("foo")
      expect(stubbed_redis).to have_received(:ttl).with("tabs:foo")
    end

    it "#get calls get with expected key" do
      subject.get("foo")
      expect(stubbed_redis).to have_received(:get).with("tabs:foo")
    end

    it "#mget receives prefixed keys" do
      subject.mget("foo", "bar")
      expect(stubbed_redis).to have_received(:mget).with("tabs:foo", "tabs:bar")
    end

    it "#set calls set with the expected key and arg" do
      subject.set("foo", "bar")
      expect(stubbed_redis).to have_received(:set).with("tabs:foo", "bar")
    end

    it "#del" do
      subject.del("foo")
      expect(stubbed_redis).to have_received(:del).with("tabs:foo")
    end

    it "#del_by_prefix" do
      allow(stubbed_redis).to receive(:keys).and_return(["foo:a", "foo:b"])
      subject.del_by_prefix("foo")
      expect(stubbed_redis).to have_received(:del).with("foo:a", "foo:b")
    end

    it "#incr" do
      subject.incr("foo")
      expect(stubbed_redis).to have_received(:incr).with("tabs:foo")
    end

    it "#rpush" do
      subject.rpush("foo", "bar")
      expect(stubbed_redis).to have_received(:rpush).with("tabs:foo", "bar")
    end

    it "#sadd" do
      subject.sadd("foo", "bar", "baz")
      expect(stubbed_redis).to have_received(:sadd).with("tabs:foo", "bar", "baz")
    end

    it "#smembers" do
      subject.smembers("foo")
      expect(stubbed_redis).to have_received(:smembers).with("tabs:foo")
    end

    it "#smembers_all" do
      expect(stubbed_redis).to receive(:pipelined).and_yield
      subject.smembers_all("foo", "bar")
      expect(stubbed_redis).to have_received(:smembers).with("tabs:foo")
      expect(stubbed_redis).to have_received(:smembers).with("tabs:bar")
    end

    it "#sismember" do
      subject.sismember("foo", "bar")
      expect(stubbed_redis).to have_received(:sismember).with("tabs:foo", "bar")
    end

    it "#hget" do
      subject.hget("foo", "bar")
      expect(stubbed_redis).to have_received(:hget).with("tabs:foo", "bar")
    end

    it "#hset" do
      subject.hset("foo", "bar", "baz")
      expect(stubbed_redis).to have_received(:hset).with("tabs:foo", "bar", "baz")
    end

    it "#hdel" do
      subject.hdel("foo", "bar")
      expect(stubbed_redis).to have_received(:hdel).with("tabs:foo", "bar")
    end

    it "#hkeys" do
      subject.hkeys("foo")
      expect(stubbed_redis).to have_received(:hkeys).with("tabs:foo")
    end

    it "#hincrby" do
      subject.hincrby("foo", "bar", 42)
      expect(stubbed_redis).to have_received(:hincrby).with("tabs:foo", "bar", 42)
    end

    it "#hgetall" do
      subject.hgetall("foo")
      expect(stubbed_redis).to have_received(:hgetall).with("tabs:foo")
    end

  end
end
