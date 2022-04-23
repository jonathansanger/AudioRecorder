//
//  AudioItemView.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/21/22.
//

import SwiftUI

struct AudioItemView: View {
	var audioItem: AudioItem
	var deleteFile: (String) -> Void
	var startPlaying: () -> Void
	var stopPlaying: () -> Void
	var isPlaying: Bool
	
	func togglePlayback() {
		if isPlaying {
			self.stopPlaying()
		}
		else {
			self.startPlaying()
		}
	}
	
	var shouldShowPlayButton: Bool {
		return !audioItem.inProgress
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
			.opacity(shouldShowPlayButton ? 1 : 0)
			
			if audioItem.inProgress {
				Text("Recording in progress...").italic()
			}
			else {
				Text(audioItem.recordingName)
			}
			
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
		AudioItemView(audioItem: AudioItem.mock, deleteFile: {_ in}, startPlaying: {}, stopPlaying: {}, isPlaying: false)
	}
}
