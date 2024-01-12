#!/usr/bin/env ruby

require 'tty-spinner'
require 'tty-progressbar'
require 'open3'
require 'shellwords'
require 'fileutils'
require 'pastel'

class ThreadedTests
  def run(pattern: '*', max_threads: 8, max_tests: 0)
    pastel = Pastel.new

    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @results = File.expand_path('results.log')

    max_threads = 1000 if max_threads.to_i == 0

    shuffle = false

    unless pattern =~ /shuffle/i
      pattern = "test/curlyq_*#{pattern}*_test.rb"
    else
      pattern = "test/curlyq_*_test.rb"
      shuffle = true
    end

    tests = Dir.glob(pattern)

    tests.shuffle! if shuffle

    if max_tests.to_i > 0
      tests = tests.slice(0, max_tests.to_i - 1)
    end

    puts pastel.cyan("#{tests.count} test files")

    banner = "Running tests [:bar] T/A (#{max_threads.to_s} threads)"

    progress = TTY::ProgressBar::Multi.new(banner,
                                           width: 12,
                                           clear: true,
                                           hide_cursor: true)
    @children = []
    tests.each do |t|
      test_name = File.basename(t, '.rb').sub(/curlyq_(.*?)_test/, '\1')
      new_sp = progress.register("[:bar] #{test_name}:status",
                                 total: tests.count + 8,
                                 width: 1,
                                 head: ' ',
                                 unknown: ' ',
                                 hide_cursor: true,
                                 clear: true)
      status = ': waiting'
      @children.push([test_name, new_sp, status])
    end

    @elapsed = 0.0
    @test_total = 0
    @assrt_total = 0
    @error_out = []
    @threads = []
    @running_tests = []

    begin
      finish_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      while @children.count.positive?

        slices = @children.slice!(0, max_threads)
        slices.each { |c| c[1].start }
        slices.each do |s|
          @threads << Thread.new do
            run_test(s)
            finish_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          end
        end

        @threads.each { |t| t.join }
      end

      finish_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      progress.finish
    rescue
      progress.stop
    ensure
      msg = @running_tests.map { |t| t[1].format.sub(/^\[:bar\] (.*?):status/, "\\1#{t[2]}") }.join("\n")

      output = []
      output << if @error_out.count.positive?
                  pastel.red("#{@error_out.count} Issues")
                else
                  pastel.green('Success')
                end
      output << pastel.green("#{@test_total} tests")
      output << pastel.cyan("#{@assrt_total} assertions")
      output << pastel.yellow("#{(finish_time - start_time).round(3)}s")
      puts output.join(', ')

      if @error_out.count.positive?
        puts @error_out.join(pastel.white("\n----\n"))
        Process.exit 1
      end
    end
  end

  def run_test(s)
    pastel = Pastel.new

    bar = s[1]
    s[2] = ": #{pastel.green('running')}"
    bar.advance(status: s[2])

    if @running_tests.count.positive?
      @running_tests.each do |b|
        prev_bar = b[1]
        if prev_bar.complete?
          prev_bar.reset
          prev_bar.advance(status: b[2])
          prev_bar.finish
        else
          prev_bar.update(head: ' ', unfinished: ' ')
          prev_bar.advance(status: b[2])
        end
      end
    end

    @running_tests.push(s)
    out, _err, status = Open3.capture3(ENV, 'rake', "test:#{s[0]}", stdin_data: nil)
    time = out.match(/^Finished in (?<time>\d+\.\d+) seconds\./)
    count = out.match(/^(?<tests>\d+) tests, (?<assrt>\d+) assertions, (?<fails>\d+) failures, (?<errs>\d+) errors/)

    unless status.success? && !count['fails'].to_i.positive? && !count['errs'].to_i.positive?
      s[2] = if count
               ": #{paste.red(count['fails'])} #{pastel.red('failures')}, #{pastel.red(count['errs'])} #{pastel.red('errors')}"
             else
               ": #{pastel.red('Unknown Error')}"
             end
      bar.update(head: pastel.red('✖'))
      bar.advance(head: pastel.red('✖'), status: s[2])

      # errs = out.scan(/(?:Failure|Error): [\w_]+\((?:.*?)\):(?:.*?)(?=\n=======)/m)
      @error_out.push(out)
      bar.finish

      next_test
      Thread.exit
    end

    s[2] = [
      ': ',
      pastel.green(count['tests']),
      '/',
      pastel.cyan(count['assrt']),
      ' ',
      pastel.yellow(time['time'].to_f.round(3).to_s),
      's'
    ].join('')
    bar.update(head: pastel.green('✔'))
    bar.advance(head: pastel.green('✔'), status: s[2])
    @test_total += count['tests'].to_i
    @assrt_total += count['assrt'].to_i
    @elapsed += time['time'].to_f

    bar.finish

    next_test
  end

  def next_test
    if @children.count.positive?
      t = Thread.new do
        s = @children.shift
        # s[1].start
        # s[1].advance(status: ": #{'running'.green}")
        run_test(s)
      end

      t.join
    end
  end
end
