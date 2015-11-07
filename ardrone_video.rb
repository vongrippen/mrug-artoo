require 'artoo'

connection :ardrone, :adaptor => :ardrone, :port => '192.168.1.1:5556'
device :drone, :driver => :ardrone, :connection => :ardrone

connection :videodrone, :adaptor => :ardrone_video, :port => '192.168.1.1:5555'
device :video, :driver => :ardrone_video, :connection => :videodrone

work do
  on video, :frame => :v_frame
  drone.start
  drone.take_off

  after(25.seconds) { drone.hover.land }
  after(30.seconds) { drone.stop }
end

def v_frame(*data)
  @count ||= 0
  @count += 1
  puts "Frame# #{@count} #{data[1].size} bytes"
end
