//
//  GPXFileManager.swift
//  OpenGpxTracker
//

import Foundation

class GPXFileManager: NSObject {

    static let gpxExtList = ["gpx", "GPX"]

    class var GPXFilesFolderURL: URL {
        if let customFolderURL = Preferences.shared.gpxFilesFolderURL {
            print("GPXFileManager: using custom folder: \(customFolderURL)")
            return customFolderURL
        }
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        return documentsUrl
    }

    class var fileList: [GPXFileInfo] {
        let documentsURL = GPXFileManager.GPXFilesFolderURL
        if documentsURL.startAccessingSecurityScopedResource() {
            let files = self.fetchFilesList(from: documentsURL)
            documentsURL.stopAccessingSecurityScopedResource()
            return files
        }
        return []
    }

    class func URLForFilename(_ filename: String) -> URL {
        var fullURL = self.GPXFilesFolderURL.appendingPathComponent(filename)
        print("URLForFilename(\(filename): pathForFilename: \(fullURL)")
        // Check if filename has extension
        if  !(gpxExtList.contains(fullURL.pathExtension)) {
            fullURL = fullURL.appendingPathExtension(gpxExtList[0])
        }
        return fullURL
    }

    class func fileExists(_ filename: String) -> Bool {
        let fileURL = self.URLForFilename(filename)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    class func saveToURL(_ fileURL: URL, gpxContents: String) {
        // 保存文件
        print("Saving file at path: \(fileURL)")
        // 将 GPX 写入文件
        var writeError: NSError?
        let saved: Bool
        do {
            try gpxContents.write(toFile: fileURL.path, atomically: true, encoding: String.Encoding.utf8)
            saved = true
        } catch let error as NSError {
            writeError = error
            saved = false
        }
        if !saved {
            if let error = writeError {
                print("[ERROR] GPXFileManager:save: \(error.localizedDescription)")
            }
        }

    }

    // 将文件名保存在默认文件夹中
    class func save(_ filename: String, gpxContents: String) {
        // 获取文件的完整URL
        let fileURL: URL = self.URLForFilename(filename)
        GPXFileManager.saveToURL(fileURL, gpxContents: gpxContents)
    }
    
    // 将从Apple Watch接收的临时文件移动到默认目录
    class func moveFrom(_ fileURL: URL, fileName: String?) {

        guard let fileName = fileName else {
            print("GPXFileManager:: save failed, error: file name is nil")
            return
        }

        do {
            let url = GPXFilesFolderURL.path + "/" + fileName
            try FileManager().moveItem(atPath: fileURL.path, toPath: url)
        }
        catch {
            print("GPXFileManager:: save failed, error: \(error)")
        }
    }
    
    // 删除指定URL上的文件
    class func removeFileFromURL(_ fileURL: URL) {
        print("Removing file at path: \(fileURL)")
        let defaultManager = FileManager.default
        var error: NSError?
        let deleted: Bool
        do {
            try defaultManager.removeItem(atPath: fileURL.path)
            deleted = true
        } catch let error1 as NSError {
            error = error1
            deleted = false
        }
        if !deleted {
            if let e = error {
                print("[ERROR] GPXFileManager:removeFile: \(fileURL) : \(e.localizedDescription)")
            }
        }
    }

    // 删除指定文件名的文件
    class func removeFile(_ filename: String) {
        let fileURL: URL = self.URLForFilename(filename)
        GPXFileManager.removeFileFromURL(fileURL)
    }

    // 删除临时目录中的所有文件
    class func removeTemporaryFiles() {
        let fileManager = FileManager.default
        do {
            let tmpDirectory = try fileManager.contentsOfDirectory(atPath: NSTemporaryDirectory())
            tmpDirectory.forEach { file in
                let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(file)
                GPXFileManager.removeFileFromURL(fileURL)
            }
        } catch {
            print(error)
        }
    }

    private class func fetchFilesList(from rootURL: URL) -> [GPXFileInfo] {
        var GPXFiles: [GPXFileInfo] = []
        let fileManager = FileManager.default
        print("====================================================================")
        do {
            if let directoryURLs = try? fileManager.contentsOfDirectory(at: rootURL,
                includingPropertiesForKeys: [.attributeModificationDateKey, .fileSizeKey],
                options: .skipsSubdirectoryDescendants) {

                let sortedURLs = directoryURLs.map { url in
                    (url: url,
                     modificationDate: (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast,
                     fileSize: (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0)
                    }
                    .sorted(by: { $0.1 > $1.1 })

                for (url, modificationDate, fileSize) in sortedURLs {
                    if gpxExtList.contains(url.pathExtension) {
                        GPXFiles.append(GPXFileInfo(fileURL: url))
                        let lastPathComponent = url.deletingPathExtension().lastPathComponent
                        print("fetchFileList: GPXFileInfo added \(modificationDate) \(modificationDate.timeAgo(numericDates: true)) \(fileSize)bytes -- \(lastPathComponent)")
                    }
                }
            }
        }
        print("fetchFilesList: returned \(GPXFiles.count) files")
        print("====================================================================")
        return GPXFiles
    }
}
