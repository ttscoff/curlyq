require 'open3'
require 'time'
$LOAD_PATH.unshift File.join(__dir__, '..', '..', 'lib')
require 'curly'

module CurlyQHelpers
  CURLYQ_EXEC = File.join(File.dirname(__FILE__), '..', '..', 'bin', 'curlyq')
  BUNDLE = '/Users/ttscoff/.asdf/shims/bundle'

  def curlyq_with_env(env, *args, stdin: nil)
    Dir.chdir(File.expand_path('~/Desktop/Code/curlyq'))
    pread(env, BUNDLE, 'exec', 'bin/curlyq', *args, stdin: stdin)
  end

  def curlyq(*args)
    curlyq_with_env({ 'GLI_DEBUG' => 'true' }, *args)
  end

  def pread(env, *cmd, stdin: nil)
    out, err, status = Open3.capture3(env, *cmd, stdin_data: stdin)
    unless status.success?
      raise [
        "Error (#{status}): #{cmd.inspect} failed", "STDOUT:", out.inspect, "STDERR:", err.inspect
      ].join("\n")
    end

    out
  end
end
