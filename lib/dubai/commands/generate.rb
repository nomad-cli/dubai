require 'fileutils'

command :generate do |c|
  c.syntax = 'pk generate PASSNAME'
  c.summary = 'Generates a template pass directory'
  c.description = ''

  c.example 'description', 'pk generate mypass'
  c.option '-T', '--type [boardingPass|coupon|eventTicket|storeCard|generic]', 'Type of pass'
  
  c.action do |args, options|
    @directory = args.first 
    @directory ||= ask "Enter a passbook name: "

    say_error "Missing pass name" and abort if @directory.nil? or @directory.empty?
    say_error "Directory #{@directory} already exists" and abort if File.directory?(@directory)
    say_error "File exists at #{@directory}" and abort if File.exist?(@directory)

    @type = options.type
    determine_type! unless @type
    validate_type!

    FileUtils.mkdir_p @directory
    FileUtils.cp File.join(File.dirname(__FILE__), '..', 'templates', "#{@type}.json"), File.join(@directory, 'pass.json')
    ['icon.png', 'icon@2x.png'].each do |file|
      FileUtils.touch File.join(@directory, file)
    end

    say_ok "Pass generated in #{@directory}"
  end
end

# alias_command :generate, :new
# alias_command :generate, :g

private

def determine_type!
  @type ||= choose "Select a pass type", *Dubai::Passbook::Pass::TYPES
end

def validate_type!
  say_error %{Invalid type: "#{@type}", expected one of: [#{Dubai::Passbook::Pass::TYPES.join(', ')}]} unless Dubai::Passbook::Pass::TYPES.include?(@type)
end
