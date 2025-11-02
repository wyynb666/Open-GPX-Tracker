import Foundation
import CoreLocation

let kDefaultsKeyTileServerInt: String = "TileServerInt"
let kDefaultsKeyUseCache: String = "UseCache"
let kDefaultsKeyUseImperial: String = "UseImperial"
let kDefaultsKeyActivityType: String = "ActivityType"
let kDefaultsKeyDateFormat: String = "DateFormat"
let kDefaultsKeyDateFormatInput: String = "DateFormatPresetInput"
let kDefaultsKeyDateFormatPreset: String = "DateFormatPreset"
let kDefaultsKeyDateFormatUseUTC: String = "DateFormatPresetUseUTC"
let kDefaultsKeyDateFormatUseEN: String = "DateFormatPresetUseEN"
let kDefaultsKeyGPXFilesFolder: String = "GPXFilesFolder"
let kDefaultsKeyKeepScreenAlwaysOn: String = "KeepScreenAlwaysOn"

class Preferences: NSObject {
    static let shared = Preferences()
    private var _useImperial: Bool = false
    private var _useCache: Bool = true
    private var _tileServer: GPXTileServer = .apple
    private var _activityType: CLActivityType = .other
    private var _dateFormat = "dd-MMM-yyyy-HHmm"
    private var _dateFormatInput = "{dd}-{MMM}-{yyyy}-{HH}{mm}"
    private var _dateFormatPreset: Int = 0
    private var _dateFormatUseUTC: Bool = false
    private var _dateFormatUseEN: Bool = false
    private var _gpxFilesFolderBookmark: Data?
    private var _keepScreenAlwaysOn: Bool = false
    private let defaults = UserDefaults.standard
    
    private override init() {
        if let useImperialDefaults = defaults.object(forKey: kDefaultsKeyUseImperial) as? Bool {
            print("** Preferences:: loaded from defaults. useImperial: \(useImperialDefaults)")
            _useImperial = useImperialDefaults
        } else {
            let locale = NSLocale.current
            _useImperial = !locale.usesMetricSystem
            let langCode = locale.languageCode ?? "unknown"
            let useMetric = locale.usesMetricSystem
            print("** Preferences:: NO defaults for useImperial. Using locale: \(langCode) useImperial: \(_useImperial) usesMetric:\(useMetric)")
        }
    
        if let useCacheFromDefaults = defaults.object(forKey: kDefaultsKeyUseCache) as? Bool {
            _useCache = useCacheFromDefaults
            print("Preferences:: loaded preference from defaults useCache= \(useCacheFromDefaults)")
        }
        
        if var tileServerInt = defaults.object(forKey: kDefaultsKeyTileServerInt) as? Int {
            tileServerInt = tileServerInt >= GPXTileServer.count ? GPXTileServer.apple.rawValue : tileServerInt
            _tileServer = GPXTileServer(rawValue: tileServerInt)!
            print("** Preferences:: loaded preference from defaults tileServerInt \(tileServerInt)")
        }
        
        if let activityTypeInt = defaults.object(forKey: kDefaultsKeyActivityType) as? Int {
            _activityType = CLActivityType(rawValue: activityTypeInt)!
            print("** Preferences:: loaded preference from defaults activityTypeInt \(activityTypeInt)")
        }
        
        if let dateFormatStr = defaults.object(forKey: kDefaultsKeyDateFormat) as? String {
            _dateFormat = dateFormatStr
            print("** Preferences:: loaded preference from defaults dateFormatStr \(dateFormatStr)")
        }
        
        if let dateFormatStrIn = defaults.object(forKey: kDefaultsKeyDateFormatInput) as? String {
            _dateFormatInput = dateFormatStrIn
            print("** Preferences:: loaded preference from defaults dateFormatStrIn \(dateFormatStrIn)")
        }
        
        if let dateFormatPresetInt = defaults.object(forKey: kDefaultsKeyDateFormatPreset) as? Int {
            _dateFormatPreset = dateFormatPresetInt
            print("** Preferences:: loaded preference from defaults dateFormatPresetInt \(dateFormatPresetInt)")
        }
        
        if let dateFormatUTCBool = defaults.object(forKey: kDefaultsKeyDateFormatUseUTC) as? Bool {
            _dateFormatUseUTC = dateFormatUTCBool
            print("** Preferences:: loaded preference from defaults dateFormatPresetUTCBool \(dateFormatUTCBool)")
        }
        
        if let dateFormatENBool = defaults.object(forKey: kDefaultsKeyDateFormatUseEN) as? Bool {
            _dateFormatUseEN = dateFormatENBool
            print("** Preferences:: loaded preference from defaults dateFormatPresetENBool \(dateFormatENBool)")
        }
        
        if let gpxFilesFolderBookmark = defaults.object(forKey: kDefaultsKeyGPXFilesFolder) as? Data {
            _gpxFilesFolderBookmark = gpxFilesFolderBookmark
            print("** Preferences:: loaded preference from defaults gpxFilesFolderBookmark \(gpxFilesFolderBookmark)")
        }

        if let keepScreenAlwaysOnBool = defaults.object(forKey: kDefaultsKeyKeepScreenAlwaysOn) as? Bool {
            _keepScreenAlwaysOn = keepScreenAlwaysOnBool
            print("** Preferences:: loaded preference from defaults keepScreenAlwaysOn \(keepScreenAlwaysOnBool)")
        }
        
    }
    
    var useImperial: Bool {
        get {
            return _useImperial
        }
        set {
            _useImperial = newValue
            defaults.set(newValue, forKey: kDefaultsKeyUseImperial)
        }
    }
    
    var useCache: Bool {
        get {
            return _useCache
        }
        set {
            _useCache = newValue
            defaults.set(newValue, forKey: kDefaultsKeyUseCache)
        }
    }
    
    var tileServer: GPXTileServer {
        get {
            return _tileServer
        }
        set {
            _tileServer = newValue
             defaults.set(newValue.rawValue, forKey: kDefaultsKeyTileServerInt)
        }
    }
    
    var tileServerInt: Int {
        get {
            return _tileServer.rawValue
        }
        set {
            _tileServer = GPXTileServer(rawValue: newValue)!
             defaults.set(newValue, forKey: kDefaultsKeyTileServerInt)
        }
    }

    var locationActivityType: CLActivityType {
        get {
            return _activityType
        }
        set {
            _activityType = newValue
            defaults.set(newValue.rawValue, forKey: kDefaultsKeyActivityType)
        }
    }
    
    var locationActivityTypeInt: Int {
        get {
            return _activityType.rawValue
        }
        set {
            _activityType = CLActivityType(rawValue: newValue)!
            defaults.set(newValue, forKey: kDefaultsKeyActivityType)
        }
    }
    
    var dateFormat: String {
        get {
            return _dateFormat
        }
        set {
             _dateFormat = newValue
             defaults.set(newValue, forKey: kDefaultsKeyDateFormat)
        }
    }
    
    var dateFormatInput: String {
        get {
            return _dateFormatInput
        }
        set {
             _dateFormatInput = newValue
             defaults.set(newValue, forKey: kDefaultsKeyDateFormatInput)
        }
    }
    
    var dateFormatPreset: Int {
        get {
            return _dateFormatPreset
        }
        set {
            _dateFormatPreset = newValue
             defaults.set(newValue, forKey: kDefaultsKeyDateFormatPreset)
        }
    }
    
    var dateFormatPresetName: String {
        let presets =  ["Defaults", "ISO8601 (UTC)", "ISO8601 (UTC offset)", "Day, Date at time (12 hr)", "Day, Date at time (24 hr)"]
        return _dateFormatPreset < presets.count ? presets[_dateFormatPreset] : "???"
    }
    
    var dateFormatUseUTC: Bool {
        get {
            return _dateFormatUseUTC
        }
        set {
            _dateFormatUseUTC = newValue
             defaults.set(newValue, forKey: kDefaultsKeyDateFormatUseUTC)
        }
    }
    
    var dateFormatUseEN: Bool {
        get {
            return _dateFormatUseEN
        }
        set {
            _dateFormatUseEN = newValue
             defaults.set(newValue, forKey: kDefaultsKeyDateFormatUseEN)
        }
    }
    
    var keepScreenAlwaysOn: Bool {
        get {
            return _keepScreenAlwaysOn
        }
        set {
            _keepScreenAlwaysOn = newValue
            defaults.set(newValue, forKey: kDefaultsKeyKeepScreenAlwaysOn)
            print("** Preferences:: setting keepScreenAlwaysOn: \(newValue)")
        }
    }
    
    var gpxFilesFolderURL: URL? {
        get {
            guard let bookmarkData = self._gpxFilesFolderBookmark else {
                return nil
            }
            do {
                var isStale: Bool = false
                let url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
                if isStale {
                    _ = url.startAccessingSecurityScopedResource()
                    defer {
                        url.stopAccessingSecurityScopedResource()
                    }
                    let newBookmark = try url.bookmarkData()
                    _gpxFilesFolderBookmark = newBookmark
                    defaults.set(newBookmark, forKey: kDefaultsKeyGPXFilesFolder)
                }
                return url
            } catch {
                print("** Preferences:: failed to retrieve url from bookmark data: \(String(describing: error))")
                return nil
            }
        }
        set {
            guard let newValue else {
                defaults.removeObject(forKey: kDefaultsKeyGPXFilesFolder)
                return
            }
            do {
                _ = newValue.startAccessingSecurityScopedResource()
                defer {
                    newValue.stopAccessingSecurityScopedResource()
                }
                let newBookmark = try newValue.bookmarkData()
                _gpxFilesFolderBookmark = newBookmark
                defaults.set(newBookmark, forKey: kDefaultsKeyGPXFilesFolder)
            } catch {
                print("** Preferences:: failed to generate bookmark data for url: \(String(describing: error))")
            }
        }
    }
}
