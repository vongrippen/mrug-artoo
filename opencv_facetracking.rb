require 'artoo'

connection :capture, :adaptor => :opencv_capture, :source => "tcp://192.168.1.1:5555"
device :capture, :driver => :opencv_capture, :connection => :capture, :interval => 0.0033

connection :video, :adaptor => :opencv_window
device :video, :driver => :opencv_window, :connection => :video, :title => "Video", :interval => 0.0033

connection :ardrone, :adaptor => :ardrone, :port => '192.168.1.1:5556'
device :drone, :driver => :ardrone, :connection => :ardrone

HAAR = "#{Dir.pwd}/haarcascade_frontalface_alt.xml"

work do
  drone.start
  drone.take_off
  after(10.seconds) {drone.hover}
  after(15.seconds) {
    every(0.5) {
      opencv = capture.opencv
      video.image = opencv.image
      detect(opencv)
    }
  }
end

def detect(opencv)
  begin
    drone.hover
    biggest = 0
    face = nil
    opencv.detect_faces(HAAR).each do |f|
      if f.width > biggest
        biggest = f.width
        face = f
      end
    end
    if !face.nil? && (face.class != OpenCV::CvSeq) && (face.width <= 100 && face.width >= 45)
      opencv.draw_rectangles!([face])
      center_x = opencv.image.width * 0.5
      turn = -( face.center.x - center_x ) / center_x
      puts "turning: #{turn}"
      if turn < 0
        drone.turn_right(turn.abs)
      else
        drone.turn_left(turn.abs)
      end
      video.image = opencv.image
    end
  rescue Exception => e
    drone.hover
    puts e.message
  end
end
