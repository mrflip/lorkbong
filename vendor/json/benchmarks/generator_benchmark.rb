#!/usr/bin/env ruby

require 'bullshit'
$KCODE='utf8'
require 'bullshit'
case ARGV.first
when 'ext'
  require 'json/ext'
when 'pure'
  require 'json/pure'
when 'rails'
  require 'active_support'
end

module JSON
  def self.[](*) end
end

module GeneratorBenchmarkCommon
  include JSON

  def setup
    a = [ nil, false, true, "fÖßÄr", [ "n€st€d", true ], { "fooß" => "bär", "quux" => true } ]
    puts a.to_json
    @big = a * 100
  end

  def generic_reset_method
    @result and @result.size > 2 + 6 * @big.size or raise @result.to_s
  end
end

module JSONGeneratorCommon
  include GeneratorBenchmarkCommon

  def benchmark_generator_fast
    @result = JSON.fast_generate(@big)
  end

  alias reset_benchmark_generator_fast generic_reset_method

  def benchmark_generator_safe
    @result = JSON.generate(@big)
  end

  alias reset_benchmark_generator_safe generic_reset_method

  def benchmark_generator_pretty
    @result = JSON.pretty_generate(@big)
  end

  alias reset_benchmark_generator_pretty generic_reset_method
end

class GeneratorBenchmarkExt < Bullshit::RepeatCase
  include JSONGeneratorCommon

  warmup      yes
  iterations  500

  truncate_data do
    alpha_level 0.05
    window_size 50
  end

  output_dir File.join(File.dirname(__FILE__), 'data')
  output_filename benchmark_name + '.log'
  data_file yes
  histogram yes
end

class GeneratorBenchmarkPure < Bullshit::RepeatCase
  include JSONGeneratorCommon

  warmup      yes
  iterations  500

  truncate_data do
    alpha_level 0.05
    window_size 50
  end

  output_dir File.join(File.dirname(__FILE__), 'data')
  output_filename benchmark_name + '.log'
  data_file yes
  histogram yes
end

class GeneratorBenchmarkRails < Bullshit::RepeatCase
  include GeneratorBenchmarkCommon

  warmup      yes
  iterations  500

  truncate_data do
    alpha_level 0.05
    window_size 50
  end

  output_dir File.join(File.dirname(__FILE__), 'data')
  output_filename benchmark_name + '.log'
  data_file yes
  histogram yes

  def benchmark_generator
    @result = @big.to_json
  end

  alias reset_benchmark_generator generic_reset_method
end

if $0 == __FILE__
  Bullshit::Case.autorun false

  case ARGV.first
  when 'ext'
    GeneratorBenchmarkExt.run
  when 'pure'
    GeneratorBenchmarkPure.run
  when 'rails'
    GeneratorBenchmarkRails.run
  else
    system "rake clean"
    system "ruby #$0 rails"
    system "ruby #$0 pure"
    system "rake compile"
    system "ruby #$0 ext"
    Bullshit.compare do
      output_filename File.join(File.dirname(__FILE__), 'data', 'GeneratorBenchmarkComparison.log')

      benchmark GeneratorBenchmarkExt,    :generator_fast,    :load => yes
      benchmark GeneratorBenchmarkExt,    :generator_safe,    :load => yes
      benchmark GeneratorBenchmarkExt,    :generator_pretty,  :load => yes
      benchmark GeneratorBenchmarkPure,   :generator_fast,    :load => yes
      benchmark GeneratorBenchmarkPure,   :generator_safe,    :load => yes
      benchmark GeneratorBenchmarkPure,   :generator_pretty,  :load => yes
      benchmark GeneratorBenchmarkRails,  :generator,         :load => yes
    end
  end
end

