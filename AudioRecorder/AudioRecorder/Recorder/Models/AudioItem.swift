//
//  AudioItem.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/22/22.
//

import Foundation

class AudioItem {
	let id: String
	var url: URL
	var recordingName: String
	
	init(id: String, url: URL, recordingName: String = "My audio recording") {
		self.id = id
		self.url = url
		self.recordingName = recordingName
	}
	
	static var mock: AudioItem {
		return AudioItem(id: "ABCDEFGH", url: URL(string: "/users/documents/myaudiofile.m4a")!)
	}
}
