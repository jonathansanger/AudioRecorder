//
//  AudioRecordingRepository.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/23/22.
//

import Foundation

let kAudioItemsArrayKey = "kAudioItemsArrayKey"

class AudioRecordingRepository: ObservableObject {
	private let localDataSource: AudioRecordingLocalDataSource
	// Create a remote class that will interact with the backend to read and write data
	// private let localRemoteSource: AudioRecordingRemoteDataSource

	static let shared = AudioRecordingRepository()
	@Published var audioCollection: AudioCollection

	init() {
		self.localDataSource = AudioRecordingLocalDataSource()
		self.audioCollection = AudioCollection()
		self.loadRecordings()
	}
	
	private func loadRecordings() {
		if let savedAudioItems = self.localDataSource.loadLocalRecordings() {
			self.audioCollection.replaceExistingWith(savedAudioItems)
		}
	}
	
	func saveRecording(audioItem: AudioItem) {
		self.audioCollection.addAudioItem(audioItem)
		self.localDataSource.saveRecordings(audioItems: self.audioCollection.audioItems)
	}
	
	func deleteOne(id: String) {
		DispatchQueue.main.async {
			self.audioCollection.deleteAudio(id: id)
			//Overwrite UserDefaults with updated data set
			self.localDataSource.saveRecordings(audioItems: self.audioCollection.audioItems)
		}
	}
	
	static func getDocDirectory() -> URL {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
	}
	
	static func getUrlForRecording(filename: String) -> URL {
		return AudioRecordingRepository.getDocDirectory().appendingPathComponent(filename)
	}
	
	class AudioRecordingLocalDataSource {
		func loadLocalRecordings() -> [AudioItem]? {
			// load user defaults, for each, check if url still exists, then addAudio
			guard let audioCollectionDictionary = UserDefaults.standard.dictionary(forKey: kAudioItemsArrayKey) else {
				return nil
			}
			
			var audioItems: [AudioItem] = []
			for audioAny in audioCollectionDictionary {
				guard let audioDict = audioAny.value as? [String: Any] else {
					return nil
				}
				guard let id = audioDict["id"] as? String, let recordingName = audioDict["recordingName"] as? String, let filename = audioDict["filename"] as? String, let creationDate = audioDict["creationDate"] as? String else {
					return nil
				}
				let audioItem = AudioItem(id: id, filename: filename, recordingName: recordingName, creationDate: creationDate)
				audioItems.append(audioItem)
			}
			return audioItems
		}
		
		func saveRecordings(audioItems: [AudioItem]) {
			var audioCollectionDict: [String: Any] = [:]
			for audioItem in audioItems {
				let itemDict: [String: Any] = ["id": audioItem.id, "filename": audioItem.filename, "recordingName": audioItem.recordingName, "creationDate": audioItem.creationDate]
				audioCollectionDict[audioItem.id] = itemDict
			}
			UserDefaults.standard.set(audioCollectionDict, forKey: kAudioItemsArrayKey)
		}
	}
}
