//
//  RecorderHelper.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/20/22.
//

import Foundation
import AVFAudio

class RecorderHelper: NSObject, AVAudioRecorderDelegate {
	var onRecordDidFinish: (Bool) -> Void
	var avAudioRecoder: AVAudioRecorder?
	
	init(url: URL, onRecordDidFinish: @escaping (Bool) -> Void) {
		let settings: [String: Any] = [
			AVFormatIDKey: kAudioFormatLinearPCM,
			AVSampleRateKey : 44100.0,
			AVNumberOfChannelsKey : 1
		]
		self.onRecordDidFinish = onRecordDidFinish
		super.init()
		do {
			let audioSession = AVAudioSession()
			try audioSession.setCategory(.playAndRecord)
			try audioSession.setActive(true)
			let avAudioRecorder: AVAudioRecorder = try AVAudioRecorder(url: url, settings: settings)
			avAudioRecorder.delegate = self
			self.avAudioRecoder = avAudioRecorder
		}
		catch {
			print(error)
		}
	}
	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		onRecordDidFinish(flag)
	}
	
	func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
		onRecordDidFinish(false)
	}
}
