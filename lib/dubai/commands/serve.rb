command :serve do |c|
  c.syntax = 'pk serve [PASSNAME]'
  c.summary = 'Creates a .pkpass archive'
  c.description = ''

  c.example 'description', 'pk archive mypass'
  c.option '-c', '--certificate /path/to/cert.pem', 'Pass certificate'
  c.option '-p', '--[no]-password', 'Prompt for certificate password'
  
  c.action do |args, options|
    determine_directory! unless @directory = args.first
    validate_directory!

    @certificate = options.certificate
    validate_certificate!

    @password = ask("Enter certificate password:"){|q| q.echo = false} if options.password

    Dubai::Passbook.certificate, Dubai::Passbook.password = @certificate, @password
    
    Dubai::Server.set :directory, @directory
    Dubai::Server.set :bind, '0.0.0.0'
    Dubai::Server.run!
  end
end

# alias_command :serve, :preview
# alias_command :serve, :s

private

def determine_directory!
  files = Dir['*/pass.json']
  @directory ||= case files.length
                 when 0 then nil
                 when 1 then File.dirname(files.first)
                 else
                   @directory = choose "Select a directory:", *files.collect{|f| File.dirname(f)}
                 end
end

def validate_directory!
  say_error "Missing argument" and abort if @directory.nil?
  say_error "Directory #{@directory} does not exist" and abort unless File.directory?(@directory)
  say_error "Directory #{@directory} is not valid pass" and abort unless File.exist?(File.join(@directory, "pass.json"))
end

def validate_certificate!
  say_error "Missing or invalid certificate file" and abort if @certificate.nil? or not File.exist?(@certificate) 
end
