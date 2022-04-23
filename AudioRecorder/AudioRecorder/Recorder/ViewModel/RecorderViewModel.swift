//
//  RecorderViewModel.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/20/22.
//

import Foundation
import AVFAudio
import SwiftUI

class RecorderViewModel: ObservableObject {
	@Published var recorderHelper: RecorderHelper?
	@Published var audioCollection: AudioCollection
	@Published var shouldRequestFileName: Bool
	@Published var activeRecording: AudioItem?
	@Published var isRecording: Bool
	
	let kAudioItemsArrayKey = "kAudioItemsArrayKey"

	init() {
		self.audioCollection = AudioCollection()
		self.shouldRequestFileName = false
		self.isRecording = false
		self.loadPreviousRecordings()
	}
	
	func loadPreviousRecordings() {
		// load user defaults, for each, check if url still exists, then addAudio
		guard let audioCollectionDictionary = UserDefaults.standard.dictionary(forKey: kAudioItemsArrayKey) else {
			return
		}
		
		for audioAny in audioCollectionDictionary {
			guard let audioDict = audioAny.value as? [String: Any] else {
				return
			}
			guard let id = audioDict["id"] as? String, let recordingName = audioDict["recordingName"] as? String, let urlPath = audioDict["url"] as? String, let creationDate = audioDict["creationDate"] as? String else {
				return
			}
			let url = URL(fileURLWithPath: urlPath)
			let fileStillExists = FileManager.default.fileExists(atPath: urlPath)
			print("fileStillExists: \(fileStillExists), url: \(url)")
			let audioItem = AudioItem(id: id, url: url, recordingName: recordingName, creationDate: creationDate)
			self.audioCollection.addAudioItem(audioItem)
		}
	}
	
	func saveRecordingsToUserDefaults() {
		var audioCollectionDict: [String: Any] = [:]
		for audioItem in audioCollection.audioItems {
			let itemDict: [String: Any] = ["id": audioItem.id, "url": audioItem.url.path, "recordingName": audioItem.recordingName, "creationDate": audioItem.creationDate]
			audioCollectionDict[audioItem.id] = itemDict
		}
		UserDefaults.standard.set(audioCollectionDict, forKey: kAudioItemsArrayKey)
	}
	
	func deleteAll() {
		audioCollection.deleteAll()
		UserDefaults.standard.set([:], forKey: kAudioItemsArrayKey)
		guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			return
		}
		guard let existingFiles = try? FileManager.default.contentsOfDirectory(atPath: path.path) else {
			return
		}

		for audioUrlString in existingFiles {
			let filepath = path.path.appending("/\(audioUrlString)")
			do {
				try FileManager.default.removeItem(atPath: filepath)
			}
			catch {
				print(error)
			}
		}
	}
	
	func resetRecorder() {
		self.activeRecording = nil
		self.recorderHelper = nil
	}
	
	func onRecordDidFinish(successful: Bool) {
		self.isRecording = false
		guard successful else {
			if let activeRecording = activeRecording {
				self.deleteFile(id: activeRecording.id)
			}
			self.resetRecorder()
			return
		}
		self.shouldRequestFileName = true
	}
	
	private func requestMicrophonePermission(recordPermission: AVAudioSession.RecordPermission) {
		switch recordPermission {
		case .undetermined:
			//Request permission, if granted, user can tap/hold record again after alert closes
			AVAudioSession().requestRecordPermission({ _ in })
		case .denied:
			let alertController = AlertController.shared
			alertController.title = "Microphone permission denied"
			alertController.message = "Please grant AudioRecorder access to the microphone."
			alertController.primaryButton = .default(Text("Open Settings")) {
				alertController.reset()
				UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
			}
			alertController.secondaryButton = .cancel()
			alertController.showAlert = true
		case .granted:
			//Already handled previously
			break
		@unknown default:
			//Request permission, if granted, user can tap/hold record again after alert closes
			AVAudioSession().requestRecordPermission({ _ in })
		}
	}
	
	func attemptStartRecording() {
		let audioSession = AVAudioSession()
		let recordPermission = audioSession.recordPermission
		if recordPermission == .granted {
			let recordingId = UUID().uuidString
			let fileName = recordingId + ".m4a"
			let fileManager = FileManager.default
			let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
			let audioItem = AudioItem(id: recordingId, url: path, creationDate: "\(Date())", inProgress: true)
			self.activeRecording = audioItem
			self.audioCollection.addAudioItem(audioItem)
			
			self.recorderHelper = RecorderHelper(url: path, onRecordDidFinish: self.onRecordDidFinish)
			guard let avRecorder = self.recorderHelper?.avAudioRecoder else {
				return
			}
			guard !avRecorder.isRecording else {
				return
			}
			self.isRecording = avRecorder.record()
		}
		else {
			self.requestMicrophonePermission(recordPermission: recordPermission)
		}
	}
	
	func stopRecording() {
		guard let recorder = recorderHelper?.avAudioRecoder else {
			self.resetRecorder()
			return
		}
		guard recorder.isRecording else {
			self.isRecording = false
			if let activeRecording = activeRecording {
				self.audioCollection.deleteAudio(id: activeRecording.id)
			}
			self.resetRecorder()
			return
		}
		recorder.stop()
		self.audioCollection.updateInProgress(false, id: activeRecording?.id)
	}
	
	func saveNewFileName(id: String, name: String) {
		self.audioCollection.updateAudioName(id: id, fileName: name)
		//Overwrite UserDefaults with updated data set
		self.saveRecordingsToUserDefaults()
		self.shouldRequestFileName = false
		self.resetRecorder()
	}
	
	func deleteFile(id: String) {
		DispatchQueue.main.async {
			self.audioCollection.deleteAudio(id: id)
			//Overwrite UserDefaults with updated data set
			self.saveRecordingsToUserDefaults()
		}
	}
}
