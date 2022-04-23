//
//  RecordButton.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/20/22.
//

import SwiftUI

struct RecordButton: View {
	@ObservedObject var viewModel: RecorderViewModel
	@GestureState var isPressedDown = false

	var recordButtonText: String {
		if viewModel.isRecording { return "Recording"}
		return "Record"
	}
	
	var body: some View {
		let tap = DragGesture(minimumDistance: 0)
			.updating($isPressedDown) { ( _, isPressedDown, _) in
			isPressedDown = true
		}
		
		return VStack {
			VStack {
				if !viewModel.isRecording {
					Text("Hold to")
						.font(.subheadline)
						.foregroundColor(.white)
				}
				Text(recordButtonText)
					.font(.title3)
					.foregroundColor(.white)
					.onChange(of: isPressedDown, perform: { _ in
						if isPressedDown && !viewModel.isRecording {
							viewModel.attemptStartRecording()
						}
						else if !isPressedDown && viewModel.isRecording {
							viewModel.stopRecording()
						}
					})
			}
			.padding(10)
			.background(Circle().fill(Color.red).scaledToFill())
			.gesture(tap)
			.padding(.bottom, 20)
		}
	}
}

struct RecordButton_Previews: PreviewProvider {
	static var previews: some View {
		RecordButton(viewModel: RecorderViewModel())
	}
}
