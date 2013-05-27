# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  
  def rotate
    manipulate! do |image|
      image.auto_orient
    end
  end
  
  version :thumb do
	process :rotate
    process resize_to_fill: [200, 200]
  end
  
  version :big do
	#process :stamp
	process :rotate
    process resize_to_fill: [500, 800]
  end
  
  def stamp
    manipulate! format: "png" do |source|
	  overlay_path = Rails.root.join("public/images/stamp_overlay.png")
      overlay = Magick::Image.read(overlay_path).first
      source = source.resize_to_fill(70, 70).quantize(256, Magick::GRAYColorspace).contrast(true)
	  #source.format = "PNG"
      source.composite!(overlay, 0, 0, Magick::OverCompositeOp)
      colored = Magick::Image.new(70, 70) { self.background_color = blue }
      colored.composite(source.negate, 0, 0, Magick::CopyOpacityCompositeOp)
    end
  end
  
end
