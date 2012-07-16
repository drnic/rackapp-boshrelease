desc "Generates a properties file for each job based on properties.X.Y used in templates"
task :job_properties do
  require "fileutils"
  Dir["jobs/*"].each do |path|
    puts "Searching job #{File.basename(path)}..."
    FileUtils.chdir(path) do
      properties = []
      Dir["templates/*.erb"].each do |template_path|
        properties |= File.read(template_path).scan(/\bproperties\.[\w\.]*\b/)
        puts properties.join("\n")
        File.open("properties", "w") { |file| file << properties.join("\n") }
      end
    end
  end
end

# Updates to latest BOSH release (dev_builds)
#
# 1. If a package has a new version, then package installed
# 2. If a job has a new version, then job templates rendered
# 3. Jobs (monit) restarted
desc "Updates to latest BOSH release"
task :update do
  
end