require 'xcodeproj'

project_path = 'ios/Runner.xcodeproj'
file_name = 'GoogleService-Info.plist'
file_path = "ios/Runner/#{file_name}"

# Open the project
project = Xcodeproj::Project.open(project_path)
target = project.targets.first # The 'Runner' target

# Check if file exists on disk
unless File.exist?(file_path)
  puts "Error: #{file_path} does not exist on disk."
  exit 1
end

# Check if file is already in the main group
group = project.main_group.find_subpath(File.join('Runner', file_name), false)
if group
  puts "#{file_name} is already in the project structure."
else
  # Add the file to the 'Runner' group
  runner_group = project.main_group.find_subpath('Runner', true)
  file_ref = runner_group.new_reference(file_name)
  puts "Added #{file_name} to project file structure."
end

# Add file to the target's build resources if not present
unless target.resources_build_phase.files_references.include?(file_ref)
  target.add_resources([file_ref])
  puts "Linked #{file_name} to Runner target build resources."
else
  puts "#{file_name} is already linked to the target."
end

# Save the project
project.save
puts "Project saved successfully."
