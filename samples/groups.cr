require "../src/honcho.cr"

sv = Honcho::Visor.new

sv.start_supervised("wait to die", Honcho::Process::Mode::ONE_SHOT) do
  sleep(1)
  raise "woops"
end


sv.start_supervised("wait to be killed", Honcho::Process::Mode::ONE_SHOT) do
  loop do
    puts "waiting to be killed"
    sleep(0.2)
  end
end

sv.start_supervised("wait to be killed 2", Honcho::Process::Mode::ONE_SHOT) do
  loop do
    puts "waiting to be killed"
    sleep(0.2)
  end
end

sv.start_supervised("wait to be killed 3", Honcho::Process::Mode::ONE_SHOT) do
  loop do
    puts "waiting to be killed"
    sleep(0.2)
  end
end

sv.start_supervised("wait to be killed 4", Honcho::Process::Mode::ONE_SHOT) do
  loop do
    puts "waiting to be killed"
    sleep(0.2)
  end
end

sv.start_supervised("wait to be killed 5", Honcho::Process::Mode::ONE_SHOT) do
  loop do
    puts "waiting to be killed"
    sleep(0.2)
  end
end

sv.run
