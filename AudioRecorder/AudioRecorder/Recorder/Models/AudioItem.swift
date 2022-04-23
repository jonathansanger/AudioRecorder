//
//  AudioItem.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/22/22.
//

import Foundation

class AudioItem: Codable {
	let id: String
	var url: URL
	var recordingName: String
	let creationDate: String
	var inProgress: Bool
	
	init(id: String, url: URL, recordingName: String = "My audio recording", creationDate: String, inProgress: Bool = false) {
		self.id = id
		self.url = url
		self.recordingName = recordingName
		self.creationDate = creationDate
		self.inProgress = inProgress
	}
	
	static var mock: AudioItem {
		return AudioItem(id: "ABCDEFGH", url: URL(string: "/users/documents/myaudiofile.m4a")!, creationDate: "\(Date())")
	}
}
