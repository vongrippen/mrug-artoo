require 'artoo'

connection :ardrone, :adaptor => :ardrone, :port => '192.168.1.1:5556'
device :drone, :driver => :ardrone, :connection => :ardrone

work do
  drone.start
  drone.take_off

  after(15.seconds) { drone.hover.land }
  after(20.seconds) { drone.stop }
end
