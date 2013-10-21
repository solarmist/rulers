# rulers/lib/rulers/file_model.rb

require "multi_json"

module Rulers
  module Model
    class FileModel
      attr_reader :id

      @@cache = {}

      @@base_dir = 'db/quotes/'

      def initialize(filename)
        @filename = filename
        # @@cache = {}
        # If filename is "dir/37.json", @id is 37
        basename = File.split(filename)[-1]

        @id = File.basename(basename, ".json").to_i

        obj = File.read(filename)
        @hash = MultiJson.load(obj)
        @@cache[@id] = self
      end

      # def method_missing(meth, *args, &block)
      #   if meth.to_s =~ /^find_all_by_(.+)$/
      #     FileModel.find($1, *args, &block)
      #   end
      # end

      # def respond_to?(method, include_private = false)
      #   if meth.to_s =~ /^find_all_by_(.+)$/
      #     true
      #   else
      #     super
      #   end
      # end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def self.find(value, type='id')
        begin
          case type.downcase
          when 'id'
            return @@cache[value.to_i] if @@cache[value]
            hash = FileModel.new("#{@@base_dir}#{value}.json")
            @@cache[hash.id] = hash
            hash
          else
            find_all_by(type, value)
          end
        rescue
          return nil
        end
      end

      def self.find_all_by(type, value)
        hashes = []
        all.each {|hash| hashes << hash if hash[type].include? value}
        hashes
      end

      def self.all
        files = Dir[@@base_dir + "*.json"]
        files.map{ |f| FileModel.new f}
      end

      def self.save(id, attrs)
        hash = find(id)
        return "HELLO" unless hash
        ["submitter", "quote", "attribution"].each do |key|
          hash[key] = attrs[key] || hash[key] || ""
        end

        File.open(@@base_dir + "#{id}.json", "w") do |f|
          f.write <<TEMPLATE
{
  "submitter": "#{hash["submitter"]}",
  "quote": "#{hash["quote"]}",
  "attribution": "#{hash["attribution"]}"
}
TEMPLATE
          @@cache[hash.id] = hash
          hash
        end

      end

      def self.create(attrs)
        hash = {}
        ["submitter", "quote", "attribution"].each do |key|
          hash[key] = attrs[key] || ""
        end

        files = Dir[@@base_dir + "*.json"]
        names = files.map { |f| f.split("/")[-1] }
        highest = names.map { |b| b.gsub(".json", "").to_i }.max
        id = highest + 1

        File.open(@@base_dir + "#{id}.json", "w") do |f|
          f.write <<TEMPLATE
{
  "submitter": "#{hash["submitter"]}",
  "quote": "#{hash["quote"]}",
  "attribution": "#{hash["attribution"]}"
}
TEMPLATE
        end

        hash = FileModel.new @@base_dir + "#{id}.json"
        @@cache[id] = hash

        hash
      end

    end
  end
end
