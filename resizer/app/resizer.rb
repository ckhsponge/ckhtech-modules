# require 'open-uri'
require 'mini_magick'
require 'aws-sdk-s3'
require 'json'

# 1. A request comes in for /#DESTINATION_DIRECTORY/#UUID/#SIZE.#FORMAT or /files/images/abcd-efgh/thumb.webp
# 2. We look in the S3 directory /#SOURCE_DIRECTORY/#UUID/#ORIGINAL_DIRECTORY/ or /source/images/abcd-efgh/oringal/
# 3. The first file found of a type in #ORIGINAL_FORMATS is resized and converted to type #FORMAT
# 4. This file is stored at the path in #1 in S3
# 4. The response is a self redirect to the path in #1, the same path in the original request
# 5. All future requests including the redirect now find the file in S3 and are NOT routed to this lambda.

ORIGINAL_FORMATS = Set.new(JSON.parse(ENV['ORIGINAL_FORMATS']))
ORIGINAL_DIRECTORY = ENV['ORIGINAL_DIRECTORY'] # defaults to 'original'
SOURCE_DIRECTORY = ENV['SOURCE_DIRECTORY'] # defaults to 'source/images'
DESTINATION_DIRECTORY = ENV['DESTINATION_DIRECTORY'] # defaults to 'files/images'
OUTPUT_FORMATS = Set.new(JSON.parse(ENV['OUTPUT_FORMATS']))
Size = Struct.new('Size',:name,:width,:height) do
  def resize?
    self.width.is_a?(Numeric) && self.height.is_a?(Numeric)
  end
end
SIZES_BY_NAME = JSON.parse(ENV['SIZES_BY_NAME']).map{|k,v| [k,Size.new(k,v['width'],v['height'])]}.to_h # string keys
BUCKET_NAME = ENV['BUCKET_NAME']
HOST_NAME = ENV['HOST_NAME']
AWS_REGION = ENV['AWS_REGION']
QUALITY = 80

class Resizer
  class << self
    def process(event:, context:)
      debug "event: " + event.inspect
      debug "context: " + context.inspect
      path = event['path'] # e.g. /files/images/abcd-efgh/thumb.webp
      debug "path: #{path}"
      size_name = path.sub(/\.[^\.]*$/,'').sub(/^.*\//,'') # e.g. thumb
      size = SIZES_BY_NAME[size_name]
      return {'statusCode' => 400, 'statusDescription' => "Invalid Size"} unless size
      directory = path.sub(/\/[^\/]*$/,'').sub(/^\//,'') # e.g. files/images/abcd-efgh
      return {'statusCode' => 400, 'statusDescription' => "Invalid source directory"} unless directory.start_with?(DESTINATION_DIRECTORY)
      uuid = directory.sub(/^.*\//,'') # e.g. abcd-efgh
      desired_format = path.split('.').last
      return {'statusCode' => 400, 'statusDescription' => "Invalid output format"} unless OUTPUT_FORMATS.include?(desired_format)

      upload_directory = "#{SOURCE_DIRECTORY}/#{uuid}/#{ORIGINAL_DIRECTORY}"
      debug "listing #{upload_directory}/"
      client = Aws::S3::Client.new( region: AWS_REGION )
      response = client.list_objects(bucket: BUCKET_NAME, prefix: "#{upload_directory}/")
      debug "#{upload_directory} contents #{response.contents}"
      return {'statusCode' => 404, 'statusDescription' => "No input file found"} unless response.contents.any?
      original_format = nil
      original_key = nil
      response.contents.each do |content|
        format = content.key.split('.').last
        if ORIGINAL_FORMATS.include?(format)
          original_format = format
          original_key = content.key
        end
      end
      return {'statusCode' => 404, 'statusDescription' => "Input format not supported or not found"} unless original_key && original_format

      debug "original_key: #{original_key}"
      response = client.get_object(bucket: BUCKET_NAME, key: original_key )

      begin
        img = MiniMagick::Image.read(response.body, original_format)
      rescue MiniMagick::Invalid => e
        debug "MiniMagick::Invalid #{e.to_s}"
        return {'statusCode' => 400, 'statusDescription' => "Invalid Format"}
      end

      img.format(desired_format)
      resize(img, size)

      result_path = "#{DESTINATION_DIRECTORY}/#{uuid}/#{size.name}.#{desired_format}"
      debug "uploading #{result_path}"
      # img.format("jpeg").quality(quality).write(output_path)
      obj = Aws::S3::Object.new(bucket_name: BUCKET_NAME, key: result_path)
      obj.upload_stream(content_type: "image/#{desired_format}") do |write_stream|
        # IO.copy_stream(URI.open('http://example.com/file.ext'), write_stream))
        img.quality(QUALITY).write(write_stream)
      end
      debug "uploaded"
      return {
        'statusCode' => 302,
        headers: {
          Location: "https://#{HOST_NAME}/#{result_path}",
          "max-age": "0", # don't cache the redirect or there will be an infinite loop
          "cache-control": "no-cache, no-store, private"
        }
      }
    end

    private

    def debug(s)
      puts s
    end

    def resize(img, size)
      return unless size.resize? # no resizing needed, exit

      w_original = img[:width].to_f
      h_original = img[:height].to_f
      debug "original #{w_original}x#{h_original}"

      # check proportions
      op_resize = if w_original * size.height < h_original * size.width
                    "#{size.width.to_i}x"
                  else
                    "x#{size.height.to_i}"
                  end

      # cannot encode HEIC so must format image FIRST
      img.combine_options do |i|
        i.resize(op_resize)
        i.gravity(:center)
        # i.quality quality.to_i if quality.to_i > 1 && quality.to_i < 100
        i.crop "#{size.width.to_i}x#{size.height.to_i}+0+0!"
      end
      debug "combined"
    end
  end
end

#URL = "https://farm4.staticflickr.com/3319/3584524809_f791a000e0_z.jpg"
# URL = "https://ewscripps.brightspotcdn.com/dims4/default/33a0fdb/2147483647/strip/true/crop/543x305+0+40/resize/1280x720!/quality/90/?url=http%3A%2F%2Fewscripps-brightspot.s3.amazonaws.com%2Fbb%2F32%2Ffd0cd22146c284197230f7a96291%2Fdog.PNG"
# OUT_PUT_FILE_PATH = './out_thumbs3.jpeg'


# content = open(URL)
# resized_content = ImageOptimizer.resize(URL, WIDTH, HEIGHT, QUALITY, OUT_PUT_FILE_PATH)
