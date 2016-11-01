//
//  main.swift
//  XLIFFix
//
//  Created by Oliver Drobnik on 02.11.15.
//  Copyright © 2015 Cocoanetics. All rights reserved.
//

import Foundation


private func writeFile(_ file: OriginalFile, toPath path: String) throws
{
	let fileManager = FileManager.default
	
	if !fileManager.fileExists(atPath: path)
	{
		try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
	}

	let languageFolder = (path as NSString).lastPathComponent
	
	guard let name = file.attributeDict?["original"],
		let transUnits = file.transUnits else {
			return
	}
	
	let fileName = (name as NSString).lastPathComponent
	let justName = (fileName as NSString).deletingPathExtension
	let outputName = justName + ".strings"
	let outputPath = (path as NSString).appendingPathComponent(outputName)
	
	var tmpStr = ""
	
	for transUnit in transUnits
	{
		if !tmpStr.isEmpty
		{
			tmpStr += "\n"
		}
		
		guard let identifier = transUnit.attributeDict?["id"] else { continue }
		
		if let note = transUnit.note
		{
			tmpStr += "/* \(note) */\n"
		}
		
		// escape double quotes to be safe
		let translation = (transUnit.target ?? transUnit.source ?? "").replacingOccurrences(of: "\"", with: "\\\"")
		tmpStr += "\"\(identifier)\" = \"\(translation)\";\n"
	}
	
	try (tmpStr as NSString).write(toFile: outputPath, atomically: true, encoding: String.Encoding.utf8.rawValue);
	
	print("\(languageFolder)\t\(outputName) ✓")
}


if CommandLine.argc<3
{
	print("Usage: XLIFFix <output_dir> <file>\n")
	exit(1)
}

let args = CommandLine.arguments
let filemgr = FileManager.default
let outputDirectory = CommandLine.arguments[1]

for i in 2..<CommandLine.argc {
	let fileName = CommandLine.arguments[Int(i)]
	
	guard let data = try? Data(contentsOf: URL(fileURLWithPath: fileName))
		else
	{
		print("Cannot load data at path \(fileName)")
		exit(1)
	}
	
	let parser = XLIFFParser(data: data)
	
	guard let files = parser?.files else {
		print("No files found in translation file")
		exit(1)
	}
	
	do {
		for file in files {
			
			guard let language = file.attributeDict?["target-language"] else {
				print("Missing target-language")
				continue
			}
			
			let languageFolder = language + ".lproj"
			let outputPath = (outputDirectory as NSString).appendingPathComponent(languageFolder)
			
			try writeFile(file, toPath: outputPath)
		}
	}
	catch let error as NSError
	{
		print("Error writing file: \(error.localizedDescription)")
		exit(1)
	}
}
