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
	
	func updateFilename(id: String, name: String) {
		self.audioCollection.updateAudioName(id: id, fileName: name)
		//Overwrite UserDefaults with updated data set
		self.localDataSource.saveRecordings(audioItems: self.audioCollection.audioItems)
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
	
	func deleteAll() {
		self.audioCollection.deleteAll()
		self.localDataSource.deleteLocalRecordings()
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
				guard let id = audioDict["id"] as? String, let recordingName = audioDict["recordingName"] as? String, let urlPath = audioDict["url"] as? String, let creationDate = audioDict["creationDate"] as? String else {
					return nil
				}
				let url = URL(fileURLWithPath: urlPath)
				//TODO: currently when the app is rebuilt and launched all the files are seen as non-existent. Perhaps get the Ids, then cycle through documents, see if those ids are there, then update url with that? for some reason it is just not loading them (and so won't play).
				let fileStillExists = FileManager.default.fileExists(atPath: urlPath)
				print("fileStillExists: \(fileStillExists), url: \(url)")
				let audioItem = AudioItem(id: id, url: url, recordingName: recordingName, creationDate: creationDate)
				audioItems.append(audioItem)
			}
			return audioItems
		}
		
		func saveRecordings(audioItems: [AudioItem]) {
			var audioCollectionDict: [String: Any] = [:]
			for audioItem in audioItems {
				let itemDict: [String: Any] = ["id": audioItem.id, "url": audioItem.url.path, "recordingName": audioItem.recordingName, "creationDate": audioItem.creationDate]
				audioCollectionDict[audioItem.id] = itemDict
			}
			UserDefaults.standard.set(audioCollectionDict, forKey: kAudioItemsArrayKey)
		}
		
		func deleteLocalRecordings() {
			UserDefaults.standard.set([:], forKey: kAudioItemsArrayKey)
			guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
				return
			}
			guard let existingFiles = try? FileManager.default.contentsOfDirectory(atPath: path.path) else {
				return
			}

			for audioUrlString in existingFiles {
				let filepath = path.path.appending("/\(audioUrlString)")
				try? FileManager.default.removeItem(atPath: filepath)
			}
		}
	}
}
