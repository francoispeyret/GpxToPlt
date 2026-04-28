import SwiftUI
import UniformTypeIdentifiers
import AppKit

extension UTType {
    static let gpxFile = UTType(importedAs: "com.topografix.gpx")
}

struct ContentView: View {
    @EnvironmentObject var langManager: LanguageManager

    @State private var trackInfo: TrackInfo?
    @State private var sourceURL: URL?
    @State private var isTargeted = false
    @State private var isConverting = false
    @State private var showPicker = false
    @State private var status: AppStatus?

    enum AppStatus: Equatable {
        case success(String)
        case failure(String)
        var isSuccess: Bool { if case .success = self { return true }; return false }
    }

    private var s: AppStrings { langManager.strings }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.bottom, 28)

            dropZone

            if let info = trackInfo {
                fileInfoCard(info)
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
                    .padding(.top, 16)
            }

            if let st = status {
                statusBadge(st)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .padding(.top, 12)
            }

            Spacer(minLength: 20)
            actionBar
        }
        .padding(28)
        .frame(width: 500, height: 460)
        .animation(.spring(duration: 0.3), value: trackInfo != nil)
        .animation(.spring(duration: 0.25), value: status)
        .fileImporter(
            isPresented: $showPicker,
            allowedContentTypes: [.gpxFile, .xml],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                loadFile(url: url)
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isTargeted, perform: handleDrop)
    }

    // MARK: - Sub-views

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor.gradient)
                    .frame(width: 44, height: 44)
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("GPX → PLT")
                    .font(.title2.bold())
                Text(s.appSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var dropZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(isTargeted
                    ? Color.accentColor.opacity(0.08)
                    : Color(nsColor: .controlBackgroundColor))

            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    isTargeted ? Color.accentColor : Color(nsColor: .separatorColor),
                    style: StrokeStyle(lineWidth: isTargeted ? 2 : 1.5, dash: [8, 5])
                )
                .animation(.easeInOut(duration: 0.15), value: isTargeted)

            VStack(spacing: 10) {
                Image(systemName: sourceURL != nil ? "doc.badge.checkmark" : "arrow.down.doc")
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(isTargeted ? .accentColor : .secondary)
                    .animation(.easeInOut(duration: 0.15), value: isTargeted)

                if let url = sourceURL {
                    Text(url.lastPathComponent)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(s.clickToChange)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                } else {
                    Text(s.dropZoneTitle)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(s.dropZoneSubtitle)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .frame(height: 148)
        .contentShape(RoundedRectangle(cornerRadius: 14))
        .onTapGesture { showPicker = true }
    }

    @ViewBuilder
    private func fileInfoCard(_ info: TrackInfo) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "point.3.connected.trianglepath.dotted")
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 5) {
                Text(info.name)
                    .font(.headline)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Label(String(format: s.points, info.pointCount), systemImage: "mappin.circle")
                    if info.hasTimestamps, let start = info.startDate, let end = info.endDate {
                        Text("·").foregroundStyle(.tertiary)
                        Text(dateRangeText(start, end))
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 6) {
                if info.hasElevation {
                    badgeLabel("mountain.2.fill", s.elevationBadge, .green)
                }
                if info.hasTimestamps {
                    badgeLabel("clock", "GPS", .blue)
                }
            }
        }
        .padding(14)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
    }

    private func badgeLabel(_ icon: String, _ label: String, _ color: Color) -> some View {
        Label(label, systemImage: icon)
            .font(.caption2.weight(.medium))
            .foregroundStyle(color)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
    }

    @ViewBuilder
    private func statusBadge(_ st: AppStatus) -> some View {
        HStack(spacing: 9) {
            Image(systemName: st.isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundStyle(st.isSuccess ? .green : .red)

            Group {
                switch st {
                case .success(let name):
                    Text(s.successPrefix + "**\(name)**")
                case .failure(let msg):
                    Text(msg)
                }
            }
            .font(.caption)
            .foregroundColor(st.isSuccess ? .primary : .red)
            .lineLimit(1)
            .truncationMode(.middle)

            Spacer()

            Button { withAnimation { status = nil } } label: {
                Image(systemName: "xmark").font(.caption2)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(st.isSuccess ? Color.green.opacity(0.08) : Color.red.opacity(0.08))
        )
    }

    private var actionBar: some View {
        HStack {
            if trackInfo != nil {
                Button(s.resetButton) { reset() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                convertFile()
            } label: {
                if isConverting {
                    HStack(spacing: 8) {
                        ProgressView().scaleEffect(0.75).frame(width: 14, height: 14)
                        Text(s.convertingLabel)
                    }
                } else {
                    Label(s.convertButton, systemImage: "arrow.right.doc.on.clipboard")
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(trackInfo == nil || isConverting)
        }
    }

    // MARK: - Actions

    private func loadFile(url: URL) {
        guard url.pathExtension.lowercased() == "gpx" else {
            withAnimation { status = .failure(s.errorBadFile) }
            return
        }
        sourceURL = url
        withAnimation { status = nil }

        Task {
            do {
                let info = try GPXParser().parse(url: url)
                await MainActor.run {
                    withAnimation { trackInfo = info }
                }
            } catch {
                await MainActor.run {
                    withAnimation {
                        trackInfo = nil
                        status = .failure(error.localizedDescription)
                    }
                }
            }
        }
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        _ = provider.loadObject(ofClass: URL.self) { url, _ in
            guard let url else { return }
            DispatchQueue.main.async { loadFile(url: url) }
        }
        return true
    }

    private func convertFile() {
        guard let info = trackInfo, let src = sourceURL else { return }
        isConverting = true
        withAnimation { status = nil }

        Task {
            do {
                let content = try PLTConverter.convert(info)
                await MainActor.run {
                    let defaultName = src.deletingPathExtension().lastPathComponent
                    let panel = NSSavePanel()
                    panel.title = s.savePanelTitle
                    panel.nameFieldStringValue = defaultName
                    panel.allowedContentTypes = [UTType(filenameExtension: "plt") ?? .plainText]
                    panel.directoryURL = src.deletingLastPathComponent()

                    if panel.runModal() == .OK, let dest = panel.url {
                        do {
                            try content.write(to: dest, atomically: true, encoding: .utf8)
                            withAnimation { status = .success(dest.lastPathComponent) }
                        } catch {
                            withAnimation {
                                status = .failure(String(format: s.errorWrite, error.localizedDescription))
                            }
                        }
                    }
                    isConverting = false
                }
            } catch {
                await MainActor.run {
                    withAnimation { status = .failure(error.localizedDescription) }
                    isConverting = false
                }
            }
        }
    }

    private func reset() {
        withAnimation {
            trackInfo = nil
            sourceURL = nil
            status = nil
        }
    }

    // MARK: - Helpers

    private func dateRangeText(_ start: Date, _ end: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        if Calendar.current.isDate(start, inSameDayAs: end) {
            return df.string(from: start)
        }
        return "\(df.string(from: start)) – \(df.string(from: end))"
    }
}

#Preview {
    ContentView()
        .environmentObject(LanguageManager())
}
