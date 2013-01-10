class World < Array

  attr_reader :day,
    :environment_stress,
    :stress_death_ratio

  def initialize
    @day = 0
    @environment_stress = 0
    @stress_death_ratio = 1.0
  end

  def population
    count {|l| l.alive }
  end

  def avg_death_interval
    inject(0.0) { |sum, l| sum + (l.alive ? l.death_interval : 0) } / population
  end

  def avg_procreate_interval
    inject(0.0) { |sum, l| sum + (l.alive ? l.procreate_interval : 0) } / population
  end

  def next_day
    @day += 1
    calc_environment_stress
    garbage_collect
  end

  private

  def calc_environment_stress
    @environment_stress = 0 
    return unless $world.population > 200

    stress = $world.population - 200
    @environment_stress = -((stress / 50) + 1).tap { |s| puts "stress: #{s}" }
    @stress_death_ratio = ((10 + [@environment_stress,0].min) / 10.0).tap { |sdr| puts "stress_death_ratio: #{sdr}" }
  end

  def garbage_collect
    reject! { |l| !l.alive } if @day % 50 == 0
  end
end

$world = World.new

class DNA
  attr_accessor :procreate_interval, :death_interval

  def initialize(procreate_interval, death_interval)
    @procreate_interval, @death_interval = procreate_interval, death_interval
  end

  def express
    [@procreate_interval, @death_interval]
  end

  def reproduce
    DNA.new(@procreate_interval + Random.rand(-1..1), @death_interval + Random.rand(-1..+1) )
  end
end

class Life
  attr_accessor :dna,
    :birthday, 
    :procreate_interval, 
    :death_interval, 
    :alive

  def initialize(day, dna)
    @birthday = day
    @dna = dna
    @procreate_interval, @death_interval = dna.express
    @death_interval > 0 ? @alive = true : @alive = false
  end

  def birth(day)
    Life.new(day, @dna.reproduce)
  end

  def die
    @alive = false
  end

  def live(day)
    new_life = nil
    new_life = birth(day) if trigger day, @procreate_interval
    die if trigger_death day
    new_life
  end

  private

  def trigger_death(day)
    trigger(day, @death_interval) || ($world.stress_death_ratio + immunity) < Random.rand
  end

  def immunity
    [@procreate_interval / 10.0, 0.8].min
  end

  def trigger(day, interval)
    return false if interval <= 0
    @alive && (day - @birthday + 1) % interval == 0
  end

end

$world << Life.new( 0, DNA.new(5, 10) )

(1..400).each do
  $world.next_day
  $world.each do |life|
    new_life = life.live($world.day)
    $world << new_life if new_life
  end
  puts "day #{$world.day} ==== pop: #{$world.population} ==== death_interval: #{$world.avg_death_interval} ==== procreate_interval: #{$world.avg_procreate_interval}"
  $stdout.flush
end

puts "Alive:              #{$world.population}"
puts "Avg Death Int:      #{$world.avg_death_interval}"
puts "Avg Procreate Int:  #{$world.avg_procreate_interval}"
