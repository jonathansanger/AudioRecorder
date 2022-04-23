//
//  AudioItem.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/22/22.
//

import Foundation

class AudioItem: Codable {
	let id: String
	var filename: String
	var recordingName: String
	let creationDate: String
	var inProgress: Bool
	
	init(id: String, filename: String, recordingName: String = "My audio recording", creationDate: String, inProgress: Bool = false) {
		self.id = id
		self.filename = filename
		self.recordingName = recordingName
		self.creationDate = creationDate
		self.inProgress = inProgress
	}
	
	static var mock: AudioItem {
		return AudioItem(id: "ABCDEFGH", filename: "myaudiofile.m4a", creationDate: "\(Date())")
	}
}
