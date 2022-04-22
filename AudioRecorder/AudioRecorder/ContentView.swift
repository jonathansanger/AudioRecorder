//
//  ContentView.swift
//  AudioRecorder
//
//  Created by Jonathan Sanger on 4/20/22.
//

import SwiftUI

struct ContentView: View {
	var viewModel = RecorderViewModel()
	var body: some View {
		VStack {
			Spacer()
			RecordView(viewModel: viewModel)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
