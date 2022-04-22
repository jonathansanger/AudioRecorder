//
//  AudioCollection.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/22/22.
//

import Foundation

class AudioCollection: ObservableObject {
	@Published var audioItems: [AudioItem]
	
	init(_ audioItems: [AudioItem] = []) {
		self.audioItems = audioItems
	}
	
	func addAudio(_ audioItem: AudioItem) {
		//only add if it doesn't already exist
		guard !self.audioItems.contains(where: {$0.id == audioItem.id}) else {
			return
		}
		self.audioItems.append(audioItem)
	}
	
	func updateAudioName(id: String, fileName: String) {
		guard let audioItem = self.audioItems.first(where: {$0.id == id}) else {
			return
		}
		audioItem.recordingName = fileName
	}
}

