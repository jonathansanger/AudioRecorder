//
//  NamingModal.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/21/22.
//

import SwiftUI

struct NamingModal: View {
	@State var text: String = ""
	@FocusState var textfieldIsFocused: Bool
	var viewModel: RecorderViewModel
	let activeRecording: AudioItem
	
	init(viewModel: RecorderViewModel, activeRecording: AudioItem) {
		self.viewModel = viewModel
		self.activeRecording = activeRecording
		self._text = State(initialValue: activeRecording.recordingName)
		self.textfieldIsFocused = false
	}
	
	func button(buttonText: String, textColor: Color, backgroundColor: Color = .clear, action: @escaping () -> Void) -> some View {
		Button(action: action) {
			backgroundColor.cornerRadius(32).opacity(0.9).frame(maxWidth: .infinity).frame(height: 50)
				.overlay(Text(buttonText).foregroundColor(textColor))
		}
	}
	
	var body: some View {
		VStack {
			HStack {
				VStack (alignment: .leading) {
					Text("Nice recording!")
					Text("Enter a name for the file and save it.")
				}
				Spacer()
			}
			TextField("Enter a title", text: $text)
				.focused($textfieldIsFocused)
				.padding()
				.background(Color.gray.cornerRadius(8).opacity(0.2))
			VStack {
				button(buttonText: "Save", textColor: .white, backgroundColor: .blue, action: {
					self.viewModel.saveNewRecording(id: activeRecording.id, name: text)
				})
				button(buttonText: "Discard file", textColor: .red, action: {
					self.viewModel.shouldRequestFileName = false
					self.viewModel.deleteFile(id: activeRecording.id)
					self.viewModel.activeRecording = nil
				})
			}.padding(.horizontal, 20)
		}
		.padding()
		.background(Color.white.cornerRadius(16).frame(maxWidth: .infinity))
		.onAppear() {
			self.textfieldIsFocused = true
		}
	}
}

struct NamingModal_Previews: PreviewProvider {
	static var previews: some View {
		NamingModal(viewModel: RecorderViewModel(), activeRecording: AudioItem.mock)
			.padding().background(Color.black.opacity(0.5))
	}
}
