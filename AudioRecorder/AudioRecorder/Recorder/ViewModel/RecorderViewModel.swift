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
	var audioRecordingRepository: AudioRecordingRepository

	init() {
		self.shouldRequestFileName = false
		self.isRecording = false
		self.audioRecordingRepository = AudioRecordingRepository.shared
		self.audioCollection = audioRecordingRepository.audioCollection
	}
	
	var recordingListToDisplay: [AudioItem] {
		var recordingList = audioCollection.audioItems
		if let activeRecording = activeRecording {
			recordingList.append(activeRecording)
		}
		return recordingList
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
			let audioItem = AudioItem(id: recordingId, filename: fileName, creationDate: "\(Date())", inProgress: true)
			self.activeRecording = audioItem
			self.recorderHelper = RecorderHelper(url: AudioRecordingRepository.getUrlForRecording(filename: fileName), onRecordDidFinish: self.onRecordDidFinish)
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
			self.resetRecorder()
			return
		}
		recorder.stop()
	}
	
	func saveNewRecording(name: String) {
		guard let activeRecording = activeRecording else {
			return
		}
		activeRecording.inProgress = false
		activeRecording.recordingName = name
		self.audioRecordingRepository.saveRecording(audioItem: activeRecording)
		self.shouldRequestFileName = false
		self.resetRecorder()
	}
	
	func deleteFile(id: String) {
		self.objectWillChange.send()
		self.audioRecordingRepository.deleteOne(id: id)
	}
}
