require "../../src/honcho.cr"

# Using the `ISOLATED` Supervisor strategy, child processes of a supervisor are
# all treated individually.
#
# If a child process dies (either by a crash or intentionally), it will be
# handled according to its mode (see `ProcessMode`). No other child processes
# of the supervisor will be affected.
#
# This strategy is useful for supervising multiple, unrelated services.


# Since `ISOLATED` is the default strategy, this argument can be omitted. It is
# simply added here for clarity in the example.
sv = Honcho::Visor.new(strategy: Honcho::Strategy::ISOLATED)

puts "Starting ISOLATED strategy example. Press Ctrl+C to exit."

sv.start_supervised("permanent service", mode: Honcho::ProcessMode::PERMANENT, delay: 3.0) do
  puts "permanent service running. will never go down"
  i = 1
  loop do
    sleep(0.4)
    puts "permanent service iteration number: #{i}"
    i += 1
  end
end

sv.start_supervised("broken service", mode: Honcho::ProcessMode::PERMANENT) do
  sleep(1)
  puts "broken service going down. will restart."
  raise "exit abnormally"
end

sv.start_supervised("one shot service", mode: Honcho::ProcessMode::ONE_SHOT) do
  sleep(5)
  puts "one shot service going down. will not restart"
  raise "exit abnormally"
end

sv.run
