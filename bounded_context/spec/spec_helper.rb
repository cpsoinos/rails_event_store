require 'bounded_context'
require 'securerandom'

TMP_ROOT   = File.join(__dir__, 'tmp')
DUMMY_ROOT = File.join(__dir__, 'dummy')

module StdoutHelper
  def silence_stdout(&block)
    $stdout = StringIO.new
    block.call
    $stdout = STDOUT
  end
end

module GeneratorHelper
  include StdoutHelper

  def destination_root
    @destination_root ||= File.join(TMP_ROOT, SecureRandom.hex)
  end

  def prepare_destination_root
    FileUtils.mkdir_p(destination_root)
    FileUtils.cp_r("#{DUMMY_ROOT}/.", destination_root)
  end

  def nuke_destination_root
    FileUtils.rm_r(destination_root)
  end

  def run_generator(generator_args)
    silence_stdout { ::BoundedContext::Generators::BoundedContextGenerator.start(generator_args, destination_root: destination_root) }
  end

  def system_run_generator(genetator_args)
    system("cd #{destination_root}; rails g bounded_context #{genetator_args.join(' ')} -q")
  end
end

RSpec.configure do |config|
  config.include GeneratorHelper

  config.around(:each) do |example|
    prepare_destination_root
    example.call
    nuke_destination_root
  end
end
