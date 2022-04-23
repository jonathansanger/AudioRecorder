//
//  AudioCollection.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/22/22.
//

import Foundation

class AudioCollection: ObservableObject {
	@Published private(set) var audioItems: [AudioItem]
	
	init(_ audioItems: [AudioItem] = []) {
		self.audioItems = audioItems
	}
	
	func addAudioItem(_ audioItem: AudioItem) {
		//only add if it doesn't already exist
		guard !self.audioItems.contains(where: {$0.id == audioItem.id}) else {
			return
		}
		self.audioItems.append(audioItem)
		self.audioItems.sort(by: {$0.creationDate < $1.creationDate})
	}
	
	func updateAudioName(id: String, fileName: String) {
		guard let audioItem = self.audioItems.first(where: {$0.id == id}) else {
			return
		}
		audioItem.recordingName = fileName
	}
	
	func updateInProgress(_ inProgress: Bool, id: String?) {
		if let audioItem = self.audioItems.first(where: {$0.id == id}) {
			audioItem.inProgress = inProgress
		}
	}
	
	func replaceExistingWith(_ audioItems: [AudioItem]) {
		self.audioItems = audioItems
		self.audioItems.sort(by: {$0.creationDate < $1.creationDate})
	}
	
	func deleteAudio(id: String) {
		self.audioItems.removeAll(where: {$0.id == id})
	}
	
	func deleteAll() {
		self.audioItems.removeAll()
	}
}

