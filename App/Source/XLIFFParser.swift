//
//  XLIFFParser.swift
//  XLIFFix
//
//  Created by Oliver Drobnik on 02.11.15.
//  Copyright © 2015 Cocoanetics. All rights reserved.
//

import Foundation

class XLIFFParser: NSObject, XMLParserDelegate {
	
	var currentFile: OriginalFile?
	var currentTransUnit: TransUnit?
	var currentString: String?
	
	internal var files: [OriginalFile] = []

	init?(data: Data)
	{
		super.init()
		
		let parser = XMLParser(data: data)
		parser.delegate = self
		
		guard parser.parse()
		else
		{
			return nil
		}
	}
	
	// MARK: - NSXMLParserDelegate
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
	{
		if (elementName == "file")
		{
			let newFile = OriginalFile()
			newFile.attributeDict = attributeDict
			files.append(newFile)
			currentFile = newFile
		}
		else if (elementName == "trans-unit")
		{
			guard let file = currentFile else { return }
			
			if file.transUnits == nil
			{
				file.transUnits = []
			}
			
			currentTransUnit =  TransUnit()
			currentTransUnit!.attributeDict = attributeDict
			file.transUnits!.append(currentTransUnit!)
		}
		
		// new element always starts a new string
		currentString = ""
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
	{
		if (elementName == "file")
		{
			currentFile = nil
		}
		else if (elementName == "trans-unit")
		{
			currentTransUnit = nil
		}
		else if (elementName == "source")
		{
			currentTransUnit?.source = currentString
		}
		else if (elementName == "target")
		{
			currentTransUnit?.target = currentString
		}
		else if (elementName == "note")
		{
			currentTransUnit?.note = currentString
		}
		
		// end of element always stops string
		currentString = ""
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String)
	{
		currentString! += string
	}
}
