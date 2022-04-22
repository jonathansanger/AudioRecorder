//
//  AudioItemView.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/21/22.
//

import SwiftUI
import AVFAudio

struct AudioItemView: View {
	var audioItem: AudioItem
	var deleteFile: (String) -> Void
	
	@State var audioPlayer: AudioPlayer?
	@State var isPlaying: Bool = false
	
	func togglePlayback() {
		//Stop if playing
		if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
			audioPlayer.stop()
			self.isPlaying = false
		}
		else {
			//play file
			let url = audioItem.url
			do {
				let audioSession = AVAudioSession()
				try audioSession.setCategory(.playback)
				try audioSession.setActive(true)
				self.audioPlayer = AudioPlayer(url: url, didFinishPlaying: {
					self.isPlaying = false
				})
				self.isPlaying = audioPlayer?.play() ?? false
			}
			catch {
				print(error)
			}
		}

	}
	
	var body: some View {
		HStack {
			Button(action: {
				self.togglePlayback()
			}) {
				Image(systemName: self.isPlaying ? "stop.circle" : "play.fill")
					.resizable().scaledToFit()
					.frame(width: 24, height: 24)
					.frame(width: 44, height: 44)
					.foregroundColor(.blue)
			}
			.buttonStyle(PlainButtonStyle())
			
			Text(audioItem.recordingName)
			
			Spacer()
			Button(action: {
				self.deleteFile(audioItem.id)
			}) {
				Image(systemName: "trash.fill")
					.resizable().scaledToFit()
					.frame(width: 24, height: 24)
					.frame(width: 44, height: 44)
					.foregroundColor(.red)
			}
			.buttonStyle(PlainButtonStyle())
		}
	}
}

struct AudioItemView_Previews: PreviewProvider {
    static var previews: some View {
		AudioItemView(audioItem: AudioItem.mock, deleteFile: {_ in})
    }
}
