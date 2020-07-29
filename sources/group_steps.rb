require 'json'

class GroupScenarios

  # get all failed scenarios
  def parse_json(json_file)
    file = File.read(json_file)
    data_hash = JSON.parse(file)

    failed_steps = Hash.new

    data_hash.each do |feature|
      feature['elements'].each do |scenarios|
        scenarios['steps'].each do |steps|
          if steps['result']['status'] == 'failed'
            hash_key = scenarios['name']
            failed_steps[hash_key] = steps['name']
          end
        end
      end
    end

    return failed_steps
  end

  def group_failed_scenarios(json_file, output_file)
    group_hash = parse_json(json_file).group_by{ |k, v| v}
    File.open(output_file, "w:UTF-8") do |file|
      group_hash.each do |step, values|
        count = values.count
        file.puts("\nНа шаге '#{step}' упало #{count} сценария:")
        values.each do |element|
          element.delete(step)
          file.puts("   #{element[0]}")
        end
      end
    end
  end
end