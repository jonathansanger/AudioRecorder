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
	
	init() {
		self.audioCollection = AudioCollection()
		self.shouldRequestFileName = false
		self.isRecording = false
	}
	
	func loadPreviousURLs() {
		guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			return
		}
		do {
			let existingFiles = try FileManager.default.contentsOfDirectory(atPath: path.path)
			for audioUrlString in existingFiles {
				var fileName = audioUrlString
				guard let periodIndex = fileName.lastIndex(where: {$0 == "."}) else {
					continue
				}
				let extensionRange = periodIndex..<fileName.endIndex
				fileName.removeSubrange(extensionRange)
				let fileUrl = URL(fileURLWithPath: path.path.appending(audioUrlString))
				let audioItem = AudioItem(id: fileName, url: fileUrl)
				self.audioCollection.addAudio(audioItem)
			}
		}
		catch {
			print(error)
		}
	}
	
	func deleteAllLocalURLs() {
		guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			print("can't find doc directory!")
			return
		}
		guard let existingFiles = try? FileManager.default.contentsOfDirectory(atPath: path.path) else {
			print("no existings files!")
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
		//handle when record finished, successfully if url, or not if nil
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
	
	func attemptStartRecording() {
		let audioSession = AVAudioSession()
		audioSession.requestRecordPermission({ granted in
			if granted {
				let recordingId = UUID().uuidString + ".m4a"
				let fileManager = FileManager.default
				let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(recordingId)
				let audioItem = AudioItem(id: recordingId, url: path)
				self.activeRecording = audioItem
				self.audioCollection.audioItems.append(audioItem)
				
				self.recorderHelper = RecorderHelper(url: path, onRecordDidFinish: self.onRecordDidFinish)
					guard let avRecorder = self.recorderHelper?.avAudioRecoder else {
						print("no recorder!")
						return
					}
					guard !avRecorder.isRecording else {
						print("can't start recording, recording already in progress")
						return
					}
					self.isRecording = avRecorder.record()
			}
			else {
				//TODO: handle permission not granted...alert??
			}
		})

	}
	
	func stopRecording() {
		guard let recorder = recorderHelper?.avAudioRecoder else {
			self.resetRecorder()
			return
		}
		guard recorder.isRecording else {
			print("can't stop recording, none in progress")
			self.isRecording = false
			self.resetRecorder()
			return
		}
		recorder.stop()
	}
	
	func saveNewFileName(id: String, name: String) {
		self.audioCollection.updateAudioName(id: id, fileName: name)
		self.shouldRequestFileName = false
		self.resetRecorder()
	}
	
	func deleteFile(id: String) {
		self.audioCollection.audioItems.removeAll(where: {$0.id == id})
	}
}
