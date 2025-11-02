import UIKit

class DefaultNameSetupViewController: UITableViewController, UITextFieldDelegate {

    var cellTextField = UITextField()
    var cellSampleLabel = UILabel()
    var processedDateFormat = String()
    var dateFormatIsInvalid = false

    let defaultDateFormat = DefaultDateFormat()
    
    var useUTC = false
    var useEN = false
    var preferences: Preferences = Preferences.shared

    let presets =  [("Defaults", "dd-MMM-yyyy-HHmm", "{dd}-{MMM}-{yyyy}-{HH}{mm}"),
                    ("ISO8601 (UTC)", "yyyy-MM-dd'T'HH:mm:ss'Z'", "{yyyy}-{MM}-{dd}T{HH}:{mm}:{ss}Z"),
                    ("ISO8601 (UTC offset)", "yyyy-MM-dd'T'HH:mm:ssZ", "{yyyy}-{MM}-{dd}T{HH}:{mm}:{ss}{Z}"),
                    ("Day, Date at time (12 hr)", "EEEE, MMM d, yyyy 'at' h:mm a", "{EEEE}, {MMM} {d}, {yyyy} at {h}:{mm} {a}"),
                    ("Day, Date at time (24 hr)", "EEEE, MMM d, yyyy 'at' HH:mm", "{EEEE}, {MMM} {d}, {yyyy} at {HH}:{mm}")]
    
    private enum Sections: Int, CaseIterable {
        case input, settings, presets
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        useUTC = preferences.dateFormatUseUTC
        useEN = preferences.dateFormatUseEN
        
        addNotificationObservers()
    }
    
    func addNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(dateButtonTapped(_:)), name: .dateFieldTapped, object: nil)
    }
    
    @objc func dateButtonTapped(_ sender: Notification) {
        if cellTextField.text != nil {
            guard let notificationValues = sender.userInfo else { return }
            
            let patternDict = notificationValues as! [String: String]
            guard let pattern = patternDict["sender"] else { return }

            cellTextField.insertText("{\(pattern)}")

        }
    }
    
    func createSimpleDateSelectionBar() -> UIToolbar {
        let bar = UIToolbar()
        let bracket = UIBarButtonItem(title: "{ ... }", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
        bracket.tag = 6
        let day = UIBarButtonItem(title: "Day", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
        day.tag = 0
        let month = UIBarButtonItem(title: "Month", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
        month.tag = 1
        let year = UIBarButtonItem(title: "Year", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
        year.tag = 2
        let hour = UIBarButtonItem(title: "Hr", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
        hour.tag = 3
        let min = UIBarButtonItem(title: "Min", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
        min.tag = 4
        let sec = UIBarButtonItem(title: "Sec", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
        sec.tag = 5

        bar.items = [bracket, day, month, year, hour, min, sec]
        bar.sizeToFit()
        
        return bar
    }
    
    @objc func buttonTapped(_ sender: UIBarButtonItem, for event: UIEvent) {
        if cellTextField.text != nil {
            switch sender.tag {
            case 0: cellTextField.insertText("{dd}")
            case 1: cellTextField.insertText("{MM}")
            case 2: cellTextField.insertText("{yyyy}")
            case 3: cellTextField.insertText("{HH}")
            case 4: cellTextField.insertText("{mm}")
            case 5: cellTextField.insertText("{ss}")
            case 6:
                cellTextField.insertText("{}")
                
                guard let currRange = cellTextField.selectedTextRange,
                      let wantedRange = cellTextField.position(from: currRange.start, offset: -1) else { return }
                cellTextField.selectedTextRange = cellTextField.textRange(from: wantedRange, to: wantedRange)
            default: return
            }
            updateSampleTextField()
        }
    }

    @objc func updateSampleTextField() {
        let processed = defaultDateFormat.getDateFormat(unprocessed: self.cellTextField.text!)
        processedDateFormat = processed.0
        dateFormatIsInvalid = processed.1
        cellSampleLabel.text = defaultDateFormat.getDate(processedFormat: processedDateFormat, useUTC: useUTC, useENLocale: useEN)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let selectedIndexPath = IndexPath(row: preferences.dateFormatPreset, section: Sections.presets.rawValue)
        tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
        useUTC = false
        lockUTCCell(useUTC)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if cellTextField.text != preferences.dateFormatInput {
            saveDateFormat(processedDateFormat, input: cellTextField.text)
        } else {
            let selectedIndexPath = IndexPath(row: preferences.dateFormatPreset, section: Sections.presets.rawValue)
            tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .checkmark
            
            if preferences.dateFormatPreset == 1 {
                useUTC = true
                lockUTCCell(useUTC)
            }
        }
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func saveDateFormat(_ dateFormat: String, input: String?, index: Int = -1) {
        guard let input = input else { return }
        print(dateFormat)
        if dateFormatIsInvalid || input.isEmpty || dateFormat.isEmpty { return }
        preferences.dateFormat = dateFormat
        preferences.dateFormatInput = input
        preferences.dateFormatPreset = index
        preferences.dateFormatUseUTC = useUTC
    }
    
    func lockUTCCell(_ state: Bool) {
        let indexPath = IndexPath(row: 0, section: Sections.settings.rawValue)
        useUTC = state
        
        tableView.cellForRow(at: indexPath)?.accessoryType = state ? .checkmark : .none
        tableView.cellForRow(at: indexPath)?.isUserInteractionEnabled = !state
        tableView.cellForRow(at: indexPath)?.textLabel?.isEnabled = !state
        updateSampleTextField()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Sections.input.rawValue: return NSLocalizedString("DEFAULT_NAME_DATE_FORMAT", comment: "no comment")
        case Sections.settings.rawValue: return NSLocalizedString("DEFAULT_NAME_SETTINGS", comment: "no comment")
        case Sections.presets.rawValue: return NSLocalizedString("DEFAULT_NAME_PRESET", comment: "no comment")
        default: fatalError("Section out of range")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == Sections.input.rawValue {
            return NSLocalizedString("DEFAULT_NAME_INPUT_FOOTER", comment: "no comment")
        } else { return nil }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Sections.input.rawValue: return 2
        case Sections.settings.rawValue:
            if Locale.current.languageCode == "en" {
                return 1
            } else {
                return 2
            }
        case Sections.presets.rawValue: return presets.count
        default: fatalError("Row out of range")
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: .default, reuseIdentifier: "inputCell")
        
        if indexPath.section == Sections.input.rawValue {
            if indexPath.row == 0 {
                cellSampleLabel = UILabel(frame: CGRect(x: 87, y: 0, width: view.frame.width - 99, height: cell.frame.height))
                cellSampleLabel.font = .boldSystemFont(ofSize: 17)
                cell.addSubview(cellSampleLabel)
                cellSampleLabel.text = ""
                updateSampleTextField()
                cellSampleLabel.adjustsFontSizeToFitWidth = true
                cell.textLabel!.text = NSLocalizedString("DEFAULT_NAME_SAMPLE_OUTPUT_TITLE", comment: "no comment")
                cell.textLabel?.font = .systemFont(ofSize: 17)
            } else if indexPath.row == 1 {
                cellTextField = UITextField(frame: CGRect(x: 22, y: 0, width: view.frame.width - 48, height: cell.frame.height))
                cellTextField.text = preferences.dateFormatInput
                updateSampleTextField()
                cellTextField.clearButtonMode = .whileEditing
                cellTextField.delegate = self
                cellTextField.returnKeyType = .done
                
                if #available(iOS 9, *) {
                    let dateFieldSelector = DateFieldTypeView(frame: CGRect(x: 0, y: 0, width: cellTextField.frame.width, height: 75))
                    cellTextField.inputAccessoryView = dateFieldSelector
                } else {
                    cellTextField.inputAccessoryView = createSimpleDateSelectionBar()
                }
                cellTextField.addTarget(self, action: #selector(updateSampleTextField), for: UIControl.Event.editingChanged)
                cell.contentView.addSubview(cellTextField)
            }
            cell.selectionStyle = .none
            cellTextField.autocorrectionType = .no
        } else if indexPath.section == Sections.settings.rawValue {
            if indexPath.row == 0 {
                cell.textLabel!.text = NSLocalizedString("DEFAULT_NAME_USE_UTC",
                                                         comment: "no comment")// "Use UTC?"
                cell.accessoryType = preferences.dateFormatUseUTC ? .checkmark : .none
                if preferences.dateFormatPreset == 1 {
                    cell.isUserInteractionEnabled = !useUTC
                    cell.textLabel?.isEnabled = !useUTC
                }
            } else if indexPath.row == 1 {
                cell.textLabel!.text = NSLocalizedString("DEFAULT_NAME_ENGLISH_LOCALE", comment: "no comment")// "Force English Locale?"
                cell.accessoryType = preferences.dateFormatUseEN ? .checkmark : .none
            }
            updateSampleTextField()
        } else if indexPath.section == Sections.presets.rawValue {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "presetCell")
            cell.textLabel?.text = presets[indexPath.row].0
            cell.detailTextLabel?.text = defaultDateFormat.getDate(processedFormat: presets[indexPath.row].1, useUTC: useUTC, useENLocale: useEN)
            
            if preferences.dateFormatPreset != -1 {
                cell.accessoryType = preferences.dateFormatPreset == indexPath.row ? .checkmark : .none
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Sections.settings.rawValue {
            if indexPath.row == 0 {
                let newUseUTC = !preferences.dateFormatUseUTC
                preferences.dateFormatUseUTC = newUseUTC
                useUTC = newUseUTC
                tableView.cellForRow(at: indexPath)?.accessoryType = newUseUTC ? .checkmark : .none
            } else if indexPath.row == 1 {
                let newUseEN = !preferences.dateFormatUseEN
                preferences.dateFormatUseEN = newUseEN
                useEN = newUseEN
                tableView.cellForRow(at: indexPath)?.accessoryType = newUseEN ? .checkmark : .none
            }
            updateSampleTextField()
        }
        if indexPath.section == Sections.presets.rawValue {
            cellTextField.text = presets[indexPath.row].2
            let selectedIndexPath = IndexPath(row: preferences.dateFormatPreset, section: indexPath.section)
            tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
            
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            preferences.dateFormatPreset = indexPath.row
            preferences.dateFormatInput = presets[indexPath.row].2
            updateSampleTextField()
            preferences.dateFormat = processedDateFormat
            if preferences.dateFormatPreset == 1 {
                lockUTCCell(true)
            } else {
                lockUTCCell(false)
            }
            preferences.dateFormatUseUTC = useUTC
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
