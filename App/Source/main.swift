//
//  main.swift
//  XLIFFix
//
//  Created by Oliver Drobnik on 02.11.15.
//  Copyright © 2015 Cocoanetics. All rights reserved.
//

import Foundation


private func writeFile(file: OriginalFile, toPath path: String) throws
{
	let fileManager = NSFileManager.defaultManager()
	
	if !fileManager.fileExistsAtPath(path)
	{
		try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
	}

	let languageFolder = (path as NSString).lastPathComponent
	
	guard let name = file.attributeDict?["original"],
		let transUnits = file.transUnits else {
			return
	}
	
	let fileName = (name as NSString).lastPathComponent
	let justName = (fileName as NSString).stringByDeletingPathExtension
	let outputName = justName + ".strings"
	let outputPath = (path as NSString).stringByAppendingPathComponent(outputName)
	
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
		let translation = (transUnit.target ?? "").stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
		tmpStr += "\"\(identifier)\" = \"\(translation)\";\n"
	}
	
	try (tmpStr as NSString).writeToFile(outputPath, atomically: true, encoding: NSUTF8StringEncoding);
	
	print("\(languageFolder)\t\(outputName) ✓")
}


if Process.argc<2
{
	print("Usage: XLIFFix <file>\n")
	exit(1)
}

let args = Process.arguments
let filemgr = NSFileManager.defaultManager()
let currentPath = filemgr.currentDirectoryPath

for i in 1..<Process.argc {
	let fileName = Process.arguments[Int(i)]
	
	guard let data = NSData(contentsOfFile: fileName)
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
			let outputPath = (currentPath as NSString).stringByAppendingPathComponent(languageFolder)
			
			try writeFile(file, toPath: outputPath)
		}
	}
	catch let error as NSError
	{
		print("Error writing file: \(error.localizedDescription)")
		exit(1)
	}
}
