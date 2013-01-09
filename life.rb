class World < Array
  def population
    count {|l| l.alive }
  end

  def avg_death_interval
    inject(0.0) { |sum, l| sum + (l.alive ? l.death_interval : 0) } / population
  end

  def avg_procreate_interval
    inject(0.0) { |sum, l| sum + (l.alive ? l.procreate_interval : 0) } / population
  end

  def environment_stress(day)
    return @environment_stress || 0 if @day == day

    @day = day
    @environment_stress = 0 
    return @environment_stress unless $world.population > 200

    stress = $world.population - 200
    @environment_stress = -((stress / 50) + 1).tap { |s| puts "stress: #{s}" }
  end
end

$world = World.new

class Life
  attr_accessor :birthday, :procreate_interval, :death_interval, :alive

  def initialize(day, procreate_interval, death_interval)
    @birthday = day
    death_interval > 0 ? @alive = true : @alive = false
    @procreate_interval = procreate_interval
    @death_interval = death_interval
  end

  def birth(day)
    Life.new(day, @procreate_interval + Random.rand(-1..1), @death_interval + 1 + Random.rand(-1..+1) + $world.environment_stress(day))
  end

  def die
    @alive = false
  end

  def live(day)
    new_life = nil
    new_life = birth(day) if trigger day, procreate_interval
    die if trigger day, death_interval
    new_life
  end

  private

  def trigger(day, interval)
    return false if interval <= 0
    @alive && (day - @birthday + 1) % interval == 0
  end

end

$world << Life.new( 0, 5, 10)

(1..40).each do |day|
  $world.each do |life|
    new_life = life.live(day)
    $world << new_life if new_life
  end
  puts "day #{day} ==== pop: #{$world.population} ==== death_interval: #{$world.avg_death_interval} ==== procreate_interval: #{$world.avg_procreate_interval}"
  $stdout.flush
end

puts "Lives:              #{$world.size}"
puts "Alive:              #{$world.population}"
puts "Avg Death Int:      #{$world.avg_death_interval}"
puts "Avg Procreate Int:  #{$world.avg_procreate_interval}"
