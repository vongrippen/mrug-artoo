require 'artoo'

connection :capture, :adaptor => :opencv_capture, :source => "tcp://192.168.1.1:5555"
device :capture, :driver => :opencv_capture, :connection => :capture, :interval => 0.025

connection :video, :adaptor => :opencv_window
device :video, :driver => :opencv_window, :connection => :video, :title => "Video", :interval => 0.025

connection :ardrone, :adaptor => :ardrone, :port => '192.168.1.1:5556'
device :drone, :driver => :ardrone, :connection => :ardrone

work do
  on capture, :frame => proc { |*value|
    begin
    opencv = value[1]
    biggest_circle = 0
    ball = nil
    opencv.detect_circles({:r =>255, :g =>255, :b =>255}, {:r => 0, :g => 0, :b => 0}).each{|circle|
      if circle.radius > biggest_circle
        biggest_circle = circle.radius
        ball = circle
      end
    }
    if !ball.nil?
      opencv.draw_circles!([ball])
      centerX = opencv.image.width * 0.5
      turnAmount = -( ball.center.x - centerX ) / centerX
      turnAmount = [1.0, turnAmount].min
      turnAmount = [-1.0, turnAmount].max
      heightAmount = 0
      puts turnAmount
      if( turnAmount.abs > heightAmount.abs )
        puts "turning " + turnAmount.to_s
        if turnAmount < 0
          drone.turn_right(turnAmount.abs)
        else
          drone.turn_left(turnAmount)
        end
        sleep 0.1
          drone.hover
      end
    end
    video.image = opencv.image if video.alive?
    rescue Exception => e
      puts e.message
    end
  }
  drone.start
  drone.take_off
  after(5.seconds) { drone.hover }
end
