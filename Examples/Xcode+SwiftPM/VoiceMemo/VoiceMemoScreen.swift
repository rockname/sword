import SwiftUI

struct VoiceMemoScreen: View {
  let viewModel: VoiceMemoViewModel

  var body: some View {
    VoiceMemoContent(
      uiState: viewModel.uiState,
      onRecordButtonTapped: {
        Task {
          await viewModel.onRecordButtonTapped()
        }
      }
    )
  }
}

struct VoiceMemoContent: View {
  let uiState: VoiceMemoUIState
  let onRecordButtonTapped: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      List {
        ForEach(uiState.recordedVoiceMemos) { voiceMemo in
          VoiceMemoRow(voiceMemo: voiceMemo)
        }
      }
      .listStyle(.plain)
      VStack(spacing: 8) {
        ZStack {
          Circle()
            .foregroundColor(Color(.secondaryLabel))
            .frame(width: 74, height: 74)

          Button {
            onRecordButtonTapped()
          } label: {
            RoundedRectangle(cornerRadius: uiState.isRecording ? 4 : 35)
              .foregroundColor(Color(.systemRed))
              .padding(uiState.isRecording ? 18 : 2)
          }
          .frame(width: 70, height: 70)
          .disabled(uiState.isStopping)
        }
        if let displayedElapsedTime = uiState.displayedElapsedTime {
          Text(displayedElapsedTime)
            .font(.body.monospacedDigit().bold())
            .foregroundStyle(Color(.label))
            .animation(.easeInOut(duration: 0.5), value: uiState.elapsedTime)
        }
      }
      .padding(16)
      .frame(maxWidth: .infinity)
      .background(Color(.secondarySystemBackground))
    }
  }
}

struct VoiceMemoRow: View {
  let voiceMemo: VoiceMemo

  var body: some View {
    ZStack(alignment: .leading) {
      HStack(spacing: 8) {
        TextField(
          "\(voiceMemo.title.isEmpty ? "Untitled" : voiceMemo.title), \(voiceMemo.date.formatted(date: .numeric, time: .shortened))",
          text: .constant(voiceMemo.title)
        )
        .frame(maxWidth: .infinity)

        Button {
        } label: {
          Image(systemName: "play.circle")
            .font(Font.system(size: 22))
        }
      }
      .frame(maxHeight: .infinity)
      .padding(.horizontal)
    }
    .buttonStyle(.borderless)
    .listRowInsets(EdgeInsets())
  }
}

#Preview {
  VoiceMemoContent(
    uiState: .init(),
    onRecordButtonTapped: {}
  )
}
