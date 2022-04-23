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

	func replaceExistingWith(_ audioItems: [AudioItem]) {
		self.audioItems = audioItems
		self.audioItems.sort(by: {$0.creationDate < $1.creationDate})
	}
	
	func deleteAudio(id: String) {
		self.audioItems.removeAll(where: {$0.id == id})
	}
}

