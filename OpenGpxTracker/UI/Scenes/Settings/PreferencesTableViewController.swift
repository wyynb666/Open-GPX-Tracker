import Foundation
import UIKit
import CoreLocation
import MapCache
import CoreServices

let kUnitsSection = 0
let kScreenSection = 1
let kCacheSection = 2
let kMapSourceSection = 3
let kActivityTypeSection = 4
let kDefaultNameSection = 5
let kGPXFilesLocationSection = 6
let kUseImperialUnitsCell = 0
let kKeepScreenAlwaysOnCell = 0
let kUseOfflineCacheCell = 0
let kClearCacheCell = 1


class PreferencesTableViewController: UITableViewController, UINavigationBarDelegate, UIDocumentPickerDelegate {

    weak var delegate: PreferencesTableViewControllerDelegate?

    var preferences: Preferences = Preferences.shared
    
    var cache: MapCache = MapCache(withConfig: MapCacheConfig(withUrlTemplate: ""))

    var cachedSize = String()
    
    // 定义navBar和Table视图的区域，设置标题，从默认值加载首选项
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height:
            self.view.frame.height - navBarFrame.height)
        
        self.title = NSLocalizedString("PREFERENCES", comment: "no comment")
        let shareItem = UIBarButtonItem(title: NSLocalizedString("DONE", comment: "no comment"),
                                        style: UIBarButtonItem.Style.plain, target: self,
                                        action: #selector(PreferencesTableViewController.closePreferencesTableViewController))
        self.navigationItem.rightBarButtonItems = [shareItem]
        
        // 为 cachedSize 设置临时值
        cachedSize = NSLocalizedString("CALCULATING", comment: "Calculating cache")
        print("PreferencesTableViewConroller: Starting cache calculation")
        // 在后台线程中计算缓存大小
        DispatchQueue.global(qos: .background).async {
            let fileSize = self.cache.diskCache.fileSize ?? 0
            self.cachedSize = Int(fileSize).asFileSize()
            // 回到主线程更新UI
            DispatchQueue.main.async {
                print("PreferencesTableViewController: Completing cache calculation")
                if let cell = self.tableView.cellForRow(at: IndexPath(row: kUseOfflineCacheCell, section: kCacheSection)) {
                    cell.detailTextLabel?.text = self.cachedSize
                }
            }
        }
    }

    @objc func closePreferencesTableViewController() {
        print("closePreferencesTableViewController()")
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    // 加载数据
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView?) -> Int {
        return 7
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case kUnitsSection: return NSLocalizedString("UNITS", comment: "no comment")
        case kCacheSection: return NSLocalizedString("CACHE", comment: "no comment")
        case kMapSourceSection: return NSLocalizedString("MAP_SOURCE", comment: "no comment")
        case kActivityTypeSection: return NSLocalizedString("ACTIVITY_TYPE", comment: "no comment")
        case kDefaultNameSection: return NSLocalizedString("DEFAULT_NAME_SECTION", comment: "no comment")
        case kGPXFilesLocationSection: return NSLocalizedString("GPX_FILES_FOLDER", comment: "no comment")
        case kScreenSection: return NSLocalizedString("SCREEN", comment: "no comment")
        default: fatalError("Unknown section")
        }
    }

    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case kCacheSection: return 2
        case kUnitsSection: return 1
        case kMapSourceSection: return GPXTileServer.count
        case kActivityTypeSection: return CLActivityType.count
        case kDefaultNameSection: return 1
        case kGPXFilesLocationSection: return 1
        case kScreenSection: return 1
        default: fatalError("Unknown section")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .value1, reuseIdentifier: "MapCell")

        // Units Section
        if indexPath.section == kUnitsSection {
             switch indexPath.row {
             case kUseImperialUnitsCell:
                cell = UITableViewCell(style: .value1, reuseIdentifier: "CacheCell")
                cell.textLabel?.text = NSLocalizedString("USE_IMPERIAL_UNITS", comment: "no comment")
                if preferences.useImperial {
                    cell.accessoryType = .checkmark
                }
             default: fatalError("Unknown section")
            }
        }
        
        // Units Section
        if indexPath.section == kScreenSection {
             switch indexPath.row {
             case kKeepScreenAlwaysOnCell:
                 cell = UITableViewCell(style: .value1, reuseIdentifier: "CacheCell")
                 cell.textLabel?.text = NSLocalizedString("KEEP_SCREEN_ALWAYS_ON", comment: "no comment")
                 if preferences.keepScreenAlwaysOn {
                    cell.accessoryType = .checkmark
                 }
             default: fatalError("Unknown section")
            }
        }
        
        // Cache Section
        if indexPath.section == kCacheSection {
            switch indexPath.row {
            case kUseOfflineCacheCell:
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CacheCell")
                cell.textLabel?.text = NSLocalizedString("OFFLINE_CACHE", comment: "no comment")
                
                cell.detailTextLabel?.text = cachedSize
                if preferences.useCache {
                    cell.accessoryType = .checkmark
                }
            case kClearCacheCell:
                cell = UITableViewCell(style: .value1, reuseIdentifier: "CacheCell")
                cell.textLabel?.text = NSLocalizedString("CLEAR_CACHE", comment: "no comment")
                cell.textLabel?.textColor = UIColor.red
            default: fatalError("Unknown section")
            }
        }
        
        // Map Section
        if indexPath.section == kMapSourceSection {
            let tileServer = GPXTileServer(rawValue: indexPath.row)
            cell.textLabel?.text = tileServer!.name
            if indexPath.row == preferences.tileServerInt {
                cell.accessoryType = .checkmark
            }
        }
        
        // Activity type section
        if indexPath.section == kActivityTypeSection {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ActivityCell")
            let activity = CLActivityType(rawValue: indexPath.row + 1)!
            cell.textLabel?.text = activity.name
            cell.detailTextLabel?.text = activity.description
            if indexPath.row + 1 == preferences.locationActivityTypeInt {
                cell.accessoryType = .checkmark
            }
        }
        
        // Default Name section
        if indexPath.section == kDefaultNameSection {
            let dateFormatter = DefaultDateFormat()
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultNameCell")
            cell.textLabel?.text = preferences.dateFormatPreset == -1 ? preferences.dateFormatInput : preferences.dateFormatPresetName
            let dateText = dateFormatter.getDate(processedFormat: preferences.dateFormat,
                                                 useUTC: preferences.dateFormatUseUTC,
                                                 useENLocale: preferences.dateFormatUseEN)
            cell.detailTextLabel?.text = dateText
            cell.accessoryType = .disclosureIndicator
        }
        
        if indexPath.section == kGPXFilesLocationSection {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "GPXFilesLocation")
            if let url = preferences.gpxFilesFolderURL {
                cell.textLabel?.text = url.lastPathComponent
            } else {
                cell.textLabel?.text = NSLocalizedString("USING_DEFAULT_FOLDER", comment: "no comment")
            }
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == kUnitsSection {
            switch indexPath.row {
            case kUseImperialUnitsCell:
                let newUseImperial = !preferences.useImperial
                preferences.useImperial = newUseImperial
                print("PreferencesTableViewController: toggle imperial units to \(newUseImperial)")
                // Update cell UI
                tableView.cellForRow(at: indexPath)?.accessoryType = newUseImperial ? .checkmark : .none
                // Notify the map
                self.delegate?.didUpdateUseImperial(newUseImperial)
            default:
                fatalError("didSelectRowAt: Unknown cell")
            }
        }
        
        if indexPath.section == kScreenSection {
            switch indexPath.row {
            case kKeepScreenAlwaysOnCell:
                let newKeepScreenAlwaysOn = !preferences.keepScreenAlwaysOn
                preferences.keepScreenAlwaysOn = newKeepScreenAlwaysOn
                print("PreferencesTableViewController: toggle keep screen always on to \(newKeepScreenAlwaysOn)")
                // Update cell UI
                tableView.cellForRow(at: indexPath)?.accessoryType = newKeepScreenAlwaysOn ? .checkmark : .none
                // Notify the map
                self.delegate?.didUpdateKeepScreenAlwaysOn(newKeepScreenAlwaysOn)
            default:
                fatalError("didSelectRowAt: Unknown cell")
            }
        }
        
        if indexPath.section == kCacheSection {  // 0 -> 设置和取消设置缓存
            switch indexPath.row {
            case kUseOfflineCacheCell:
                print("toggle cache")
                let newUseCache = !preferences.useCache // toggle
                preferences.useCache = newUseCache
                // 更新单元格
                tableView.cellForRow(at: indexPath)?.accessoryType = newUseCache ? .checkmark : .none
                // 通知地图
                self.delegate?.didUpdateUseCache(newUseCache)
            case kClearCacheCell:
                print("clear cache")
                // 清除缓存
                cache.clear {
                    print("Cache cleaned")
                    let cell = tableView.cellForRow(at: indexPath)!
                    cell.textLabel?.text = NSLocalizedString("CACHE_IS_EMPTY", comment: "no comment")
                    cell.textLabel?.textColor = UIColor.gray

                    let cell2 = tableView.cellForRow(at: IndexPath(row: kUseOfflineCacheCell, section: kCacheSection))
                    self.cachedSize = 0.asFileSize()
                    cell2?.detailTextLabel?.text = self.cachedSize
                }
            default:
                fatalError("didSelectRowAt: Unknown cell")
            }
        }
        
        if indexPath.section == kMapSourceSection {
            print("PreferenccesTableView Map Tile Server section Row at index:  \(indexPath.row)")
            
            // 从上一个tile server中删除复选标记
            let selectedTileServerIndexPath = IndexPath(row: preferences.tileServerInt, section: indexPath.section)
            tableView.cellForRow(at: selectedTileServerIndexPath)?.accessoryType = .none
            
            // 为新tile server添加复选标记
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            preferences.tileServerInt = indexPath.row
            
            // Update map
            self.delegate?.didUpdateTileServer((indexPath as NSIndexPath).row)
        }
        
        if indexPath.section == kActivityTypeSection {
            print("PreferencesTableView Activity Type section Row at index:  \(indexPath.row + 1)")
            let selected = IndexPath(row: preferences.locationActivityTypeInt - 1, section: indexPath.section)
            
            tableView.cellForRow(at: selected)?.accessoryType = .none
            
            // 为新活动类型添加复选标记
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            preferences.locationActivityTypeInt = indexPath.row + 1 // +1 因为 activityType 原始值从索引1开始
            
            self.delegate?.didUpdateActivityType((indexPath as NSIndexPath).row + 1)
        }
        
        if indexPath.section == kDefaultNameSection {
            print("PreferencesTableView Default Name cell clicked")
            self.navigationController?.pushViewController(DefaultNameSetupViewController(style: .grouped), animated: true)
        }
        
        if indexPath.section == kGPXFilesLocationSection {
            print("PreferencesTableView GPX Files Location cell clicked")
            let documentVC = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
            documentVC.allowsMultipleSelection = false
            documentVC.delegate = self
            self.present(documentVC, animated: true)
        }
        
        // Unselect row
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let folderURL = urls.first else {
            print("Didn't select any folder")
            return
        }
        preferences.gpxFilesFolderURL = folderURL
        tableView.reloadData()
    }
}
