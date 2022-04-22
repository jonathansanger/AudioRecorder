//
//  RecordView.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/21/22.
//

import SwiftUI



struct RecordView: View {
	@ObservedObject var viewModel: RecorderViewModel
	@ObservedObject var audioCollection: AudioCollection
	
	init(viewModel: RecorderViewModel) {
		self.viewModel = viewModel
		self.audioCollection = viewModel.audioCollection
	}
	
	var body: some View {
		Self._printChanges()
		return ZStack {
			VStack {
				//Audio items list
				ScrollView {
					VStack {
						Text(viewModel.isRecording ? "Recording" : "Not recording")
						Button(action: {
							viewModel.loadPreviousURLs()
						}) {
							Text("load previous files")
						}
						Button(action: {
							viewModel.deleteAllLocalURLs()
							self.viewModel.audioCollection.audioItems.removeAll()
						}) {
							Text("Remove all urls and files")
						}
						.padding(.bottom, 32)
						ForEach(audioCollection.audioItems, id: \.id) { audioItem in
							AudioItemView(audioItem: audioItem, deleteFile: { id in
								self.viewModel.deleteFile(id: id)
							})
						}
					}
				}
				
				//Record
				VStack {
					Spacer()
					RecordButton(viewModel: viewModel)
						.disabled(viewModel.shouldRequestFileName)
				}
			}
			//Darkened overlay when file naming appears
			.overlay(Color.black.opacity(viewModel.shouldRequestFileName ? 0.7 : 0).ignoresSafeArea())
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		
		//File naming modal
		.overlay(VStack {
			if viewModel.shouldRequestFileName, let activeRecording = viewModel.activeRecording {
				NamingModal(viewModel: viewModel, activeRecording: activeRecording)
			}
		})
		
	}
}

struct RecordView_Previews: PreviewProvider {
	static var previews: some View {
		RecordView(viewModel: RecorderViewModel())
	}
}
