require "../src/honcho.cr"

sv = Honcho::Visor.new(strategy: Honcho::Strategy::UNIFIED)

sv.start_supervised("disruptor", Honcho::ProcessMode::ONE_SHOT) do
  sleep(1)
  puts "disruptor crashing now."
  raise "woops"
end

sv.start_supervised("permanent child", Honcho::ProcessMode::PERMANENT) do
  puts "permanent child started"
  loop do
    puts "permanent child looping"
    sleep(0.4)
  end
end

sv.run
