import Foundation
import UIKit
import CoreGPX
import MessageUI
import WatchConnectivity
import CoreServices

let kNoFiles = NSLocalizedString("NO_FILES", comment: "no comment")


class GPXFilesTableViewController: UITableViewController, UINavigationBarDelegate, UIDocumentPickerDelegate {
    var fileList: NSMutableArray = [kNoFiles]
    var gpxFilesFound = false
    var selectedRowIndex = -1
    weak var delegate: GPXFilesTableViewControllerDelegate?
    var folderLabel: UILabel = UILabel()
    // 设置视图控制器
    // 设置标题和文件夹
    // 添加“完成”并选择文件夹按钮
    // 加载现有的 GPX 文件列表
    override func viewDidLoad() {
        /*
         super.viewDidLoad()
         let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
         self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height:
         self.view.frame.height - navBarFrame.height)
         
         self.title = NSLocalizedString("YOUR_FILES", comment: "no comment")
         
         // 添加文件时重新加载表
         addNotificationObservers()

         let shareItem = UIBarButtonItem(title: NSLocalizedString("DONE", comment: "no comment"),
         style: UIBarButtonItem.Style.plain,
         target: self,
         action: #selector(GPXFilesTableViewController.closeGPXFilesTableViewController))
         
         self.navigationItem.rightBarButtonItems = [shareItem]
         */
        super.viewDidLoad()
        if let appDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("App Documents Directory: \(appDirectory.path)")
            
        }
        let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height: self.view.frame.height - navBarFrame.height)
        
        // 将自定义标题和副标题视图添加到导航栏
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))

        // 标题标签
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("YOUR_FILES", comment: "no comment")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 子标题标签
        folderLabel.text = GPXFileManager.GPXFilesFolderURL.lastPathComponent
        folderLabel.font = UIFont.systemFont(ofSize: 13)
        folderLabel.textColor = .gray
        folderLabel.textAlignment = .center
        folderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 将标签添加到 titleView
        titleView.addSubview(titleLabel)
        titleView.addSubview(folderLabel)
        
        // 为标题和副标题标签添加约束
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            
            folderLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            folderLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            folderLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            folderLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor)
        ])
        
        // 将自定义视图分配给导航项的 titleView
        self.navigationItem.titleView = titleView

        let shareItem = UIBarButtonItem(title: NSLocalizedString("DONE", comment: "no comment"),
                                        style: UIBarButtonItem.Style.plain,
                                        target: self,
                                        action: #selector(GPXFilesTableViewController.closeGPXFilesTableViewController))
        
        self.navigationItem.rightBarButtonItems = [shareItem]

        var folderButton: UIBarButtonItem = UIBarButtonItem()
        if #available(iOS 13.0, *) {
            folderButton = UIBarButtonItem(image: UIImage(systemName: "folder"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(folderButtonTapped))
            
        } else {
            folderButton = UIBarButtonItem(title: NSLocalizedString("FOLDER", comment: "no comment"),
                                           style: UIBarButtonItem.Style.plain,
                                           target: self,
                                           action: #selector(folderButtonTapped))
            
        }
        self.navigationItem.leftBarButtonItems = [folderButton]
        
        _ = GPXFileManager.GPXFilesFolderURL.startAccessingSecurityScopedResource()

        let list: [GPXFileInfo] = GPXFileManager.fileList
        gpxFilesFound =  list.count != 0
        self.fileList.removeAllObjects()
        if gpxFilesFound {
            self.fileList.addObjects(from: list)
        } else {
            self.fileList.addObjects(from: [kNoFiles])
        }
    }

    deinit {
        GPXFileManager.GPXFilesFolderURL.stopAccessingSecurityScopedResource()
        NotificationCenter.default.removeObserver(self)
    }

    // 关闭view controller.
    @objc func closeGPXFilesTableViewController() {
        print("GPXFIlesTableViewController: closeGPXFIlesTableViewController()")
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    // 处理文件夹按钮行为
    @objc func folderButtonTapped() {
        print("GPXFIlesTableViewController: Folder button tapped")
        let documentVC = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
        documentVC.allowsMultipleSelection = false
        documentVC.delegate = self
        self.present(documentVC, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView?) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return fileList.count
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return gpxFilesFound
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            actionDeleteFileAtIndex((indexPath as NSIndexPath).row)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if gpxFilesFound {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
            let gpxFileInfo = fileList.object(at: (indexPath as NSIndexPath).row) as! GPXFileInfo
            let lastSaved = NSLocalizedString("LAST_SAVED", comment: "no comment")
            cell.textLabel?.text = gpxFileInfo.fileName
            cell.detailTextLabel?.text = String(format: lastSaved, gpxFileInfo.modifiedDatetimeAgo, gpxFileInfo.fileSizeHumanised)
            if #available(iOS 13, *) {
                cell.detailTextLabel?.textColor = UIColor.secondaryLabel
            } else {
                cell.detailTextLabel?.textColor = UIColor.darkGray
            }
            return cell
        } else {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
            cell.textLabel?.text = fileList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sheet = UIAlertController(title: nil, message: NSLocalizedString("SELECT_OPTION", comment: "no comment"), preferredStyle: .actionSheet)
        let mapOption = UIAlertAction(title: NSLocalizedString("LOAD_IN_MAP", comment: "no comment"), style: .default) { _ in
            self.actionLoadFileAtIndex(indexPath.row)
        }
        let shareOption = UIAlertAction(title: NSLocalizedString("SHARE", comment: "no comment"), style: .default) { _ in
            self.actionShareFileAtIndex(indexPath.row, tableView: tableView, indexPath: indexPath)
        }
        
        let cancelOption = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "no comment"), style: .cancel) { _ in
            self.actionSheetCancel(sheet)
        }
        
        let deleteOption = UIAlertAction(title: NSLocalizedString("DELETE", comment: "no comment"), style: .destructive) { _ in
            self.actionDeleteFileAtIndex(indexPath.row)
        }
        
        sheet.addAction(mapOption)
        sheet.addAction(shareOption)
        sheet.addAction(cancelOption)
        sheet.addAction(deleteOption)
        
        var cellRect = tableView.rectForRow(at: indexPath)
        cellRect.origin = CGPoint(x: 0, y: 0)
        
        sheet.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        sheet.popoverPresentationController?.sourceRect = cellRect
        
        self.present(sheet, animated: true) {
            print("Loaded actionSheet")
        }
    }
    
    // 仅当有文件时才突出显示行。
    override func tableView(_ tableView: UITableView,
                            shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return gpxFilesFound
    }

    internal func fileListObjectTitle(_ rowIndex: Int) -> String {
        return (fileList.object(at: rowIndex) as! GPXFileInfo).fileName
    }

    internal func actionSheetCancel(_ actionSheet: UIAlertController) {
        print("ActionSheet cancel")
    }

    internal func actionDeleteFileAtIndex(_ rowIndex: Int) {
        
        guard let fileURL: URL = (fileList.object(at: rowIndex) as? GPXFileInfo)?.fileURL else {
            print("GPXFileTableViewController:: actionDeleteFileAtIndex: failed to get fileURL")
            return
        }
        GPXFileManager.removeFileFromURL(fileURL)

        fileList.removeObject(at: rowIndex)
        let indexPath = IndexPath(row: rowIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        tableView.reloadData()
    }
    
    // 给定一个GPX文件将文件加载到地图
    func loadGPXFile(gpxFileURL: URL) {

        self.displayLoadingFileAlert(true)
        DispatchQueue.global(qos: .userInitiated).async {
            print("GPXFIlesTableViewController:: loadGPXFile Load gpx File: \(gpxFileURL)")
            if GPXFileManager.GPXFilesFolderURL.startAccessingSecurityScopedResource() {
                defer {
                    GPXFileManager.GPXFilesFolderURL.stopAccessingSecurityScopedResource()
                }
                do {
                    DispatchQueue.main.sync {
                        self.displayLoadingFileAlert(true)
                    }
                    guard let gpx = GPXParser(withURL: gpxFileURL)?.parsedData() else {
                        print("GPXFileTableViewController:: load of GPX file failed")
                        DispatchQueue.main.sync {
                            Toast.error("Could not open file")
                            self.displayLoadingFileAlert(false)
                        }
                        return
                    }
                    DispatchQueue.main.sync {
                        self.displayLoadingFileAlert(false) {
                            self.delegate?.didLoadGPXFileWithName(gpxFileURL.deletingPathExtension().lastPathComponent, gpxRoot: gpx)
                            self.dismiss(animated: true, completion: nil)
                            self.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            } else {
                print("Could not access folder: \(GPXFileManager.GPXFilesFolderURL)")
                DispatchQueue.main.sync {
                    Toast.error("Could not open file")
                    self.displayLoadingFileAlert(false)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
            
    // 加载文件到地图
    internal func actionLoadFileAtIndex(_ rowIndex: Int) {
        guard let gpxFileInfo: GPXFileInfo = (self.fileList.object(at: rowIndex) as? GPXFileInfo) else {
            print("GPXFileTableViewController:: actionLoadFileAtIndex(\(rowIndex)): failed to get fileURL")
            return
        }
        print("GPXFileTableViewController:: Load gpx File: \(gpxFileInfo.fileName)")
        print("GPXFileTableViewController:: Load gpx URL: \(gpxFileInfo.fileURL)")
        loadGPXFile(gpxFileURL: gpxFileInfo.fileURL)
    }
    
    // 显示加载文件警报
    func displayLoadingFileAlert(_ loading: Bool, completion: (() -> Void)? = nil) {
        // 显示或隐藏加载文件警报
        let alertController = UIAlertController(title: NSLocalizedString("LOADING_FILE", comment: "no comment"), message: nil, preferredStyle: .alert)
        let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 35, y: 30, width: 32, height: 32))
        activityIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        activityIndicatorView.style = .whiteLarge
        
        if #available(iOS 13, *) {
            activityIndicatorView.color = .blackAndWhite
        } else {
            activityIndicatorView.color = .black
        }
        
        if loading {
            activityIndicatorView.startAnimating()
            alertController.view.addSubview(activityIndicatorView)
            self.present(alertController, animated: true, completion: nil)
        } else {
            activityIndicatorView.stopAnimating()
        }

        guard let completion = completion else { return }
        completion()
    }

    internal func actionShareFileAtIndex(_ rowIndex: Int, tableView: UITableView, indexPath: IndexPath) {
        guard let gpxFileInfo: GPXFileInfo = (fileList.object(at: rowIndex) as? GPXFileInfo) else {
            print("Unable to get filename at row \(rowIndex), cannot respond to \(type(of: self))didSelectRowAt")
            return
        }
        print("GPXTableViewController: actionShareFileAtIndex")
        
        let activityViewController = UIActivityViewController(activityItems: [gpxFileInfo.fileURL], applicationActivities: nil)
        
        var cellRect = tableView.rectForRow(at: indexPath)
        cellRect.origin = CGPoint(x: 0, y: 0)
        
        activityViewController.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        activityViewController.popoverPresentationController?.sourceRect = cellRect

        activityViewController.completionWithItemsHandler = {
            (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // 用户取消
                print("actionShareAtIndex: Cancelled")
                return
            }
            // 用户完成活动
            print("actionShareFileAtIndex: User completed activity")
        }
        self.present(activityViewController, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else {
            print("GPXFilesTableViewController: documentPicker: User didn't select any folder")
            return
        }
        // 用户选择了一个文件或文件夹
        print("GPXFilesTableViewController: documentPicker:  selected URL \(selectedURL)")

        if GPXFileManager.gpxExtList.contains(selectedURL.pathExtension) {
            print("GPXFilesTableViewController: documentPicker: elected URL is a GPX File. Loading it")
            loadGPXFile(gpxFileURL: selectedURL)
            return
        }
        // 保存所选文件夹 URL 到首选项
        Preferences.shared.gpxFilesFolderURL = selectedURL
        
        folderLabel.text = selectedURL.lastPathComponent
        reloadTableData()
    }

    func addNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(reloadTableData),
                                       name: .didReceiveFileFromURL, object: nil)
        notificationCenter.addObserver(self, selector: #selector(reloadTableData), name: .didReceiveFileFromAppleWatch, object: nil)
    }

    @objc func reloadTableData() {
        print("TableViewController: reloadTableData")
        let list: [GPXFileInfo] = GPXFileManager.fileList
        fileList.removeAllObjects()
        gpxFilesFound = list.count > 0
        if (gpxFilesFound) {
            fileList.addObjects(from: list)
        } else {
            fileList.addObjects(from: [kNoFiles])
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
