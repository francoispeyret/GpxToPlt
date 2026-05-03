import SwiftUI
import UniformTypeIdentifiers
import AppKit

extension UTType {
    static let gpxFile = UTType(importedAs: "com.topografix.gpx")
}

struct ContentView: View {
    @EnvironmentObject var langManager: LanguageManager

    @State private var files: [ConversionFile] = []
    @State private var outputDir: URL?
    @State private var isTargeted = false
    @State private var isBatchConverting = false
    @State private var showPicker = false
    @State private var globalStatus: GlobalStatus?

    enum GlobalStatus: Equatable {
        case success(Int)
        case partial(Int, Int) // convertis, total
        var isSuccess: Bool { if case .success = self { return true }; return false }
    }

    private var s: AppStrings { langManager.strings }
    private var readyCount: Int { files.filter(\.isReady).count }
    private var canConvert: Bool { readyCount > 0 && !isBatchConverting }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.bottom, 20)

            dropZone
                .animation(.spring(duration: 0.3), value: files.isEmpty)

            if !files.isEmpty {
                fileList
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
                    .padding(.top, 12)
            }

            outputFolderRow
                .padding(.top, 12)

            if let st = globalStatus {
                globalStatusBadge(st)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .padding(.top, 10)
            }

            Spacer(minLength: 16)
            actionBar
        }
        .padding(24)
        .frame(width: 520, height: 560)
        .animation(.spring(duration: 0.3), value: files.count)
        .animation(.spring(duration: 0.25), value: globalStatus)
        .fileImporter(
            isPresented: $showPicker,
            allowedContentTypes: [.gpxFile, .xml],
            allowsMultipleSelection: true
        ) { result in
            if case .success(let urls) = result {
                addFiles(urls: urls.filter { $0.pathExtension.lowercased() == "gpx" })
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

            VStack(spacing: 8) {
                Image(systemName: files.isEmpty ? "arrow.down.doc" : "doc.on.doc.fill")
                    .font(.system(size: files.isEmpty ? 36 : 28, weight: .light))
                    .foregroundColor(isTargeted ? .accentColor : (files.isEmpty ? .secondary : .accentColor))
                    .animation(.easeInOut(duration: 0.15), value: isTargeted)

                if files.isEmpty {
                    Text(s.dropZoneTitle)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(s.dropZoneSubtitle)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                } else {
                    Text(String(format: s.filesLoaded, files.count))
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(s.dropMoreFiles)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .frame(height: files.isEmpty ? 148 : 100)
        .contentShape(RoundedRectangle(cornerRadius: 14))
        .onTapGesture { showPicker = true }
    }

    private var fileList: some View {
        ScrollView {
            VStack(spacing: 2) {
                ForEach(files) { file in
                    fileRow(file)
                }
            }
            .padding(6)
        }
        .frame(maxHeight: 180)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
    }

    private func fileRow(_ file: ConversionFile) -> some View {
        HStack(spacing: 8) {
            statusIcon(file.status)
                .frame(width: 16)

            Text(file.displayName)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.middle)

            if let info = file.info {
                Text("·")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
                Text(String(format: s.points, info.pointCount))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if case .failed(let msg) = file.status {
                Text(msg)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: 130)
            }

            Button {
                removeFile(file)
            } label: {
                Image(systemName: "xmark.circle")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
    }

    @ViewBuilder
    private func statusIcon(_ status: ConversionFile.FileStatus) -> some View {
        switch status {
        case .pending:
            Image(systemName: "circle.dashed")
                .foregroundStyle(.secondary).font(.caption)
        case .loading:
            ProgressView().scaleEffect(0.55)
        case .ready:
            Image(systemName: "checkmark.circle")
                .foregroundStyle(Color.accentColor).font(.caption)
        case .converting:
            ProgressView().scaleEffect(0.55)
        case .done:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green).font(.caption)
        case .failed:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red).font(.caption)
        }
    }

    private var outputFolderRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "folder")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 1) {
                Text(s.outputFolderLabel)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text(outputDir.map { ($0.path as NSString).abbreviatingWithTildeInPath } ?? s.sameAsSource)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundStyle(outputDir == nil ? .tertiary : .primary)
            }

            Spacer()

            Button(s.chooseFolderButton) {
                let panel = NSOpenPanel()
                panel.canChooseFiles = false
                panel.canChooseDirectories = true
                panel.allowsMultipleSelection = false
                panel.title = s.chooseFolderTitle
                if panel.runModal() == .OK {
                    outputDir = panel.url
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            if outputDir != nil {
                Button {
                    outputDir = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func globalStatusBadge(_ st: GlobalStatus) -> some View {
        HStack(spacing: 9) {
            Image(systemName: st.isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundStyle(st.isSuccess ? .green : .orange)

            Group {
                switch st {
                case .success(let n):
                    Text(String(format: s.successMultiple, n))
                case .partial(let ok, let total):
                    Text(String(format: s.partialSuccess, ok, total))
                }
            }
            .font(.caption)
            .foregroundColor(.primary)

            Spacer()

            Button { withAnimation { globalStatus = nil } } label: {
                Image(systemName: "xmark").font(.caption2)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(st.isSuccess ? Color.green.opacity(0.08) : Color.orange.opacity(0.08))
        )
    }

    private var actionBar: some View {
        HStack {
            if !files.isEmpty {
                Button(s.resetButton) { reset() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                convertAll()
            } label: {
                if isBatchConverting {
                    HStack(spacing: 8) {
                        ProgressView().scaleEffect(0.75).frame(width: 14, height: 14)
                        Text(s.convertingLabel)
                    }
                } else {
                    Label(
                        readyCount > 0
                            ? String(format: s.convertAllButton, readyCount)
                            : s.convertButton,
                        systemImage: "arrow.right.doc.on.clipboard"
                    )
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canConvert)
        }
    }

    // MARK: - Actions

    private func addFiles(urls: [URL]) {
        let existing = Set(files.map(\.url))
        let newURLs = urls.filter { !existing.contains($0) }
        guard !newURLs.isEmpty else { return }

        if outputDir == nil, let first = newURLs.first {
            outputDir = first.deletingLastPathComponent()
        }

        let newFiles = newURLs.map { ConversionFile(url: $0) }
        withAnimation { files.append(contentsOf: newFiles) }

        for file in newFiles {
            loadInfo(for: file)
        }
    }

    private func loadInfo(for file: ConversionFile) {
        guard let idx = files.firstIndex(where: { $0.id == file.id }) else { return }
        files[idx].status = .loading

        Task {
            do {
                let info = try GPXParser().parse(url: file.url)
                await MainActor.run {
                    if let i = files.firstIndex(where: { $0.id == file.id }) {
                        files[i].info = info
                        files[i].status = .ready
                    }
                }
            } catch {
                let msg = error.localizedDescription
                await MainActor.run {
                    if let i = files.firstIndex(where: { $0.id == file.id }) {
                        files[i].status = .failed(msg)
                    }
                }
            }
        }
    }

    private func removeFile(_ file: ConversionFile) {
        withAnimation { files.removeAll { $0.id == file.id } }
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        var urls: [URL] = []
        let group = DispatchGroup()

        for provider in providers {
            group.enter()
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                if let url, url.pathExtension.lowercased() == "gpx" {
                    urls.append(url)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.addFiles(urls: urls)
        }
        return true
    }

    private func convertAll() {
        let readyFiles = files.filter(\.isReady)
        guard !readyFiles.isEmpty else { return }

        let capturedOutputDir = outputDir
        isBatchConverting = true
        withAnimation { globalStatus = nil }

        Task {
            var successCount = 0

            for file in readyFiles {
                guard let info = file.info else { continue }

                await MainActor.run {
                    if let i = files.firstIndex(where: { $0.id == file.id }) {
                        files[i].status = .converting
                    }
                }

                do {
                    let content = try PLTConverter.convert(info)
                    let destDir = capturedOutputDir ?? file.url.deletingLastPathComponent()
                    let destName = file.url.deletingPathExtension().lastPathComponent + ".plt"
                    let destURL = destDir.appendingPathComponent(destName)

                    try content.write(to: destURL, atomically: true, encoding: .utf8)
                    successCount += 1

                    let name = destName
                    await MainActor.run {
                        if let i = files.firstIndex(where: { $0.id == file.id }) {
                            files[i].status = .done(name)
                        }
                    }
                } catch {
                    let msg = error.localizedDescription
                    await MainActor.run {
                        if let i = files.firstIndex(where: { $0.id == file.id }) {
                            files[i].status = .failed(msg)
                        }
                    }
                }
            }

            let total = readyFiles.count
            let finalCount = successCount
            await MainActor.run {
                isBatchConverting = false
                withAnimation {
                    globalStatus = finalCount == total
                        ? .success(finalCount)
                        : .partial(finalCount, total)
                }
            }
        }
    }

    private func reset() {
        withAnimation {
            files = []
            outputDir = nil
            globalStatus = nil
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LanguageManager())
}
