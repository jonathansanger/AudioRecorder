//
//  AudioPlayer.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/22/22.
//

import Foundation
import AVFAudio

class AudioPlayer: NSObject, AVAudioPlayerDelegate {
	var avAudioPlayer: AVAudioPlayer?
	var didFinishPlaying: () -> Void
	
	init(url: URL, didFinishPlaying: @escaping () -> Void) {
		self.didFinishPlaying = didFinishPlaying
		super.init()
		self.avAudioPlayer = try? AVAudioPlayer(contentsOf: url)
		self.avAudioPlayer?.delegate = self
	}
	
	func stop() {
		self.avAudioPlayer?.stop()
	}
	
	func play() -> Bool {
		let isPlaying = self.avAudioPlayer?.play()
		return isPlaying ?? false
	}
	
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		self.didFinishPlaying()
	}
}
