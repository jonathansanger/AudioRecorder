//
//  RecordView.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/21/22.
//

import SwiftUI

struct RecordView: View {
	@ObservedObject var viewModel: RecorderViewModel
	@ObservedObject var alertController: AlertController
	@State var showAlert: Bool

	init(viewModel: RecorderViewModel) {
		self.viewModel = viewModel
		self.alertController = AlertController.shared
		self._showAlert = State(initialValue: false)
	}
	
	var body: some View {
		Self._printChanges()
		return ZStack {
			VStack {
				//Audio items list
				if viewModel.recordingListToDisplay.isEmpty {
					Spacer()
					VStack {
						HStack {
							Text("Press and hold the button below to record your first audio clip!").fixedSize(horizontal: false, vertical: true).padding(.horizontal, 32)
						}
						.padding(.bottom, 20)
						Image(systemName: "arrow.down").resizable().scaledToFit().frame(width: 40)
					}
					Spacer()
					
				}
				else {
					ScrollView {
						VStack {
							ForEach(viewModel.recordingListToDisplay, id: \.id) { audioItem in
								AudioItemView(audioItem: audioItem, deleteFile: { id in
									viewModel.deleteFile(id: id)
								}).padding(.horizontal, 20)
							}
						}.frame(maxWidth: .infinity)
						Spacer()
					}
				}
				
				//Record
				VStack {
					RecordButton(viewModel: viewModel)
						.disabled(viewModel.shouldRequestFileName)
				}
			}
			//Darkened overlay when file naming appears
			.overlay(Color.black.opacity(viewModel.shouldRequestFileName ? 0.7 : 0).ignoresSafeArea())
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		
		.overlay(VStack {
			//File naming modal
			if viewModel.shouldRequestFileName, let activeRecording = viewModel.activeRecording {
				NamingModal(viewModel: viewModel, activeRecording: activeRecording)
			}
		})
		.alert(isPresented: $alertController.showAlert) { () -> Alert in
			if let secondaryButton = alertController.secondaryButton {
				return Alert(title: Text(alertController.title), message: Text(alertController.message), primaryButton: alertController.primaryButton, secondaryButton: secondaryButton)
			}
			return Alert(title: Text(alertController.title), message: Text(alertController.message), dismissButton: alertController.primaryButton)
		}
	}
}

struct RecordView_Previews: PreviewProvider {
	static var previews: some View {
		RecordView(viewModel: RecorderViewModel())
	}
}
