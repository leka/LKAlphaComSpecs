#!/usr/bin/env ruby

require 'yaml'

yaml = YAML.load_file('./Specs/LKAlphaComSpecs.yml')

com_specs = ""
com_specs_file_name = "LKAlphaComSpecs.swift"
com_specs_file = "./Sources/#{com_specs_file_name}"

format_command = "swiftformat --disable blankLinesAtEndOfScope,blankLinesAtStartOfScope #{com_specs_file}"
compile_command = "swift #{com_specs_file}"

def parse_yaml(yaml_data, output_file)

	for k in yaml_data.keys

		if !yaml_data[k].is_a?(Hash)

			if yaml_data[k].is_a?(Array)
				output_file << "\tpublic static let #{k} :[UInt8] = [#{yaml_data[k].map{ |v| sprintf("0x%02X",v)  }.join(", ")}]\n"
			elsif k == "LEKA_ALPHA_COM_SPECS"
				output_file << "\tpublic let #{k} :String = \"#{yaml_data[k]}\"\n"
			elsif yaml_data[k].is_a?(String)
				output_file << "\tpublic static let #{k} :UInt8 = #{yaml_data[k]}\n"
			else
				output_file << "\tpublic static let #{k} :UInt8 = #{sprintf("0x%02X", yaml_data[k])};\n"
			end

		else

			output_file << "\npublic struct #{k} {\n\n"
			parse_yaml(yaml_data[k], output_file)
			output_file << "\n}\n"

		end

	end
end

com_specs << """
//
//  #{com_specs_file_name}
//
//  Generated by Ladislas de Toldi on #{Time.now.strftime("%Y/%m/%d") }.
//  Copyright © 2018 Leka Inc. All rights reserved.
//

import Foundation

"""

parse_yaml(yaml, com_specs)

File.open("#{com_specs_file}", "w") {|f| f.write(com_specs) }

puts
cmd_format = system(format_command)
cmd_compile = system(compile_command)

file_output = File.read(com_specs_file);
puts file_output;
