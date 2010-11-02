#!/usr/bin/env ruby

require 'test/unit'
require 'json/add/rails'
require 'date'

class TC_JSONRails < Test::Unit::TestCase
  include JSON

  class A
    def initialize(a)
      @a = a
    end

    attr_reader :a

    def ==(other)
      a == other.a
    end
    
    def self.json_create(object)
      new(*object['args'])
    end

    def to_json(*args)
      {
        'json_class'  => self.class.name,
        'args'        => [ @a ],
      }.to_json(*args)
    end
  end

  class B
    def self.json_creatable?
      false
    end

    def to_json(*args)
      {
        'json_class'  => self.class.name,
      }.to_json(*args)
    end
  end

  class C
    def to_json(*args)
      {
        'json_class'  => 'TC_JSONRails::Nix',
      }.to_json(*args)
    end
  end

  class D
    def initialize
      @foo = 666
    end

    attr_reader :foo

    def ==(other)
      foo == other.foo
    end
  end

  def setup
    $KCODE = 'UTF8'
  end

  def test_extended_json
    a = A.new(666)
    assert A.json_creatable?
    assert_equal 666, a.a
    json = generate(a)
    a_again = JSON.parse(json)
    assert_kind_of a.class, a_again
    assert_equal a, a_again
    assert_equal 666, a_again.a
  end

  def test_extended_json_generic_object
    d = D.new
    assert D.json_creatable?
    assert_equal 666, d.foo
    json = generate(d)
    d_again = JSON.parse(json)
    assert_kind_of d.class, d_again
    assert_equal d, d_again
    assert_equal 666, d_again.foo
  end

  def test_extended_json_disabled
    a = A.new(666)
    assert A.json_creatable?
    json = generate(a)
    a_again = JSON.parse(json, :create_additions => true)
    assert_kind_of a.class, a_again
    assert_equal a, a_again
    a_hash = JSON.parse(json, :create_additions => false)
    assert_kind_of Hash, a_hash
    assert_equal(
      {"args"=>[666], "json_class"=>"TC_JSONRails::A"}.sort_by { |k,| k },
      a_hash.sort_by { |k,| k }
    )
  end

  def test_extended_json_fail1
    b = B.new
    assert !B.json_creatable?
    json = generate(b)
    assert_equal({ 'json_class' => B.name }, JSON.parse(json))
  end

  def test_extended_json_fail2
    c = C.new # with rails addition all objects are theoretically creatable
    assert C.json_creatable?
    json = generate(c)
    assert_raises(ArgumentError) { JSON.parse(json) }
  end

  def test_raw_strings
    raw = ''
    raw_array = []
    for i in 0..255
      raw << i
      raw_array << i
    end
    json = raw.to_json_raw
    json_raw_object = raw.to_json_raw_object
    hash = { 'json_class' => 'String', 'raw'=> raw_array }
    assert_equal hash, json_raw_object
    json_raw = <<EOT.chomp
{\"json_class\":\"String\",\"raw\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255]}
EOT
# "
    assert_equal json_raw, json
    raw_again = JSON.parse(json)
    assert_equal raw, raw_again
  end

  def test_symbol
    assert_equal '"foo"', JSON(:foo) #  we don't want an object here
  end
end