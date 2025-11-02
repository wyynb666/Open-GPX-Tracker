import UIKit


@available(iOS 9.0, *)
class DateFieldTypeView: UIScrollView {
    
    // MARK：本地化字符串
    private let kSingleDigit = NSLocalizedString("SINGLE_DIGIT", comment: "")
    private let kFull = NSLocalizedString("FULL_TEXT", comment: "")
    private let kText = NSLocalizedString("TEXT", comment: "")
    
    private let kOfMonth = NSLocalizedString("OF_MONTH", comment: "")
    private let kOfYear = NSLocalizedString("OF_YEAR", comment: "")
    
    private let kAbbr = NSLocalizedString("ABBR_GMT", comment: "")
    private let kUTCoffset = NSLocalizedString("UTC_OFFSET", comment: "")
    private let kGMTshort = NSLocalizedString("GMT_SHORT", comment: "")
    private let kGMTfull = NSLocalizedString("GMT_FULL", comment: "")
    private let kLocation = NSLocalizedString("LOCATION", comment: "")
    private let kLocationTime = NSLocalizedString("LOCATION_TIME", comment: "")
    
    /// 当前日期格式化
    private let dateFormatter = DateFormatter()
    
    /// 日期字段结构体
    private var dateFields: [DateField] {
        var fields = [DateField]()

        fields.append(DateField(type: NSLocalizedString("YEAR", comment: ""),
                                patterns: ["YY", "YYYY"]))
        fields.append(DateField(type: NSLocalizedString("MONTH", comment: ""),
                                patterns: ["M", "MM", "MMMMM", "MMM", "MMMM"],
                                subtitles: ["M": kSingleDigit,
                                            "MMMMM": "•",
                                            "MMM": "• • •",
                                            "MMMM": kFull]))
        fields.append(DateField(type: NSLocalizedString("DAY", comment: ""),
                                patterns: ["d", "dd", "D"],
                                subtitles: ["d": kSingleDigit,
                                            "dd": kOfMonth,
                                            "D": kOfYear]))
        fields.append(DateField(type: NSLocalizedString("HOUR", comment: ""),
                                patterns: ["h", "hh", "H", "HH", "K", "KK", "k", "kk"],
                                subtitles: ["h": kSingleDigit, "hh": "12hr",
                                            "H": kSingleDigit, "HH": "24hr",
                                            "K": kSingleDigit, "KK": "0-11",
                                            "k": kSingleDigit, "kk": "1-24"]))
        fields.append(DateField(type: NSLocalizedString("MINUTE", comment: ""),
                                patterns: ["m", "mm"],
                                subtitles: ["m": kSingleDigit]))
        fields.append(DateField(type: NSLocalizedString("SECOND", comment: ""),
                                patterns: ["s", "ss"],
                                subtitles: ["s": kSingleDigit]))
        fields.append(DateField(type: NSLocalizedString("DAY_OF_THE_WEEK", comment: ""),
                                patterns: ["e", "ee", "EEEEE", "EEEEEE", "E", "EEEE"],
                                subtitles: ["e": kSingleDigit,
                                            "EEEEE": "•",
                                            "EEEEEE": "• •",
                                            "E": "• • •",
                                            "EEEE": kFull]))
        fields.append(DateField(type: NSLocalizedString("TIME_OF_DAY", comment: ""),
                                patterns: ["aaaaa", "a", "B"],
                                subtitles: ["aaaaa": kSingleDigit,
                                            "B": "Text"]))
        fields.append(DateField(type: NSLocalizedString("WEEK", comment: ""),
                                patterns: ["w", "ww", "W"],
                                subtitles: ["w": kSingleDigit,
                                            "ww": kOfYear,
                                            "W": kOfMonth]))
        fields.append(DateField(type: NSLocalizedString("QUARTER", comment: ""),
                                patterns: ["Q", "QQ", "QQQ", "QQQQ"]))
        fields.append(DateField(type: NSLocalizedString("ERA", comment: ""),
                                patterns: ["GGGGG", "G", "GGGG"]))
        fields.append(DateField(type: NSLocalizedString("TIME_ZONE", comment: ""),
                                patterns: ["X", "Z", "ZZZZZ", "z", "O", "ZZZZ", "zzzz", "VVV", "VVVV"],
                                subtitles: ["z": kAbbr,
                                            "zzzz": kFull,
                                            "X": kUTCoffset,
                                            "O": kGMTshort,
                                            "ZZZZ": kGMTfull,
                                            "VVV": kLocation,
                                            "VVVV": kLocationTime]))

        return fields
    }
    // Default initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewDidInit()
    }
    
    // Default initializer
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        viewDidInit()
    }
    
    // 视图成功初始化后
    func viewDidInit() {
        if #available(iOS 13.0, *) {
            self.backgroundColor = .keyboardColor
        } else {
            self.backgroundColor = .lightKeyboard
        }

        let scrollStack = UIStackView()
        scrollStack.axis = .horizontal
        scrollStack.distribution = .fill
        scrollStack.alignment = .leading
        scrollStack.spacing = 25
        scrollStack.translatesAutoresizingMaskIntoConstraints = false
        
        for field in dateFields {
            let vStack = genVStack(field: field)
            scrollStack.addArrangedSubview(vStack)
        }
        
        self.addSubview(scrollStack)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[sStack]-20-|",
                                                           options: .alignAllLeft,
                                                           metrics: nil,
                                                           views: ["sStack": scrollStack]))
    }
    
    // 生成封装文本标题的垂直堆栈，所有日期模式均为相同类型。
    func genVStack(field: DateField) -> UIStackView {
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.distribution = .fill
        vStack.alignment = .leading
        vStack.spacing = 0
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        let textTitle = UIInsetLabel()
        textTitle.text = field.type.uppercased()
        textTitle.textColor = .gray
        textTitle.font = .boldSystemFont(ofSize: 14)
        textTitle.insets = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 0)
        
        vStack.addArrangedSubview(textTitle)
        vStack.addArrangedSubview(genHStack(field: field))
        
        return vStack
        
    }
    
    // 生成水平堆栈以包含所有日期模式按钮
    func genHStack(field: DateField) -> UIStackView {
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.alignment = .leading
        hStack.spacing = 10
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        for pattern in field.patterns {
            let button = DatePatternButton(type: .custom)
            button.layer.cornerRadius = 10

            dateFormatter.dateFormat = pattern
            let currentDateExample = dateFormatter.string(from: Date())
            button.setTitle(currentDateExample, for: .normal)
            button.titleLabel?.text = currentDateExample
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            
            // 设置按钮外观
            if #available(iOS 13, *) {
                button.setTitleColor(.blackAndWhite, for: .normal)
            } else {
                button.setTitleColor(.black, for: .normal)
            }
            
            // 设置按钮背景颜色
            button.pattern = pattern
            
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)

            // 检查是否有字幕
            if let subtitle = field.subtitles?[pattern] {
                hStack.addArrangedSubview(genSubtitleView(subtitle: subtitle, button: button))
            } else {
                hStack.addArrangedSubview(button)
            }
        }
        
        return hStack
    }
    
    // 生成带有字幕的垂直堆栈视图
    func genSubtitleView(subtitle: String, button: DatePatternButton) -> UIStackView {
        let subtitleLabel = UIInsetLabel()
        let subVStack = UIStackView()
        subVStack.axis = .vertical
        subVStack.distribution = .fill
        subVStack.alignment = .leading
        subVStack.spacing = -2.5
        subVStack.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        subtitleLabel.text = subtitle.uppercased()
        subtitleLabel.font = .boldSystemFont(ofSize: 8)
        subtitleLabel.textAlignment = .center
        
        subVStack.addArrangedSubview(button)
        subVStack.addArrangedSubview(subtitleLabel)
        let subtitleConstraint = NSLayoutConstraint(item: subtitleLabel,
                                                    attribute: .width,
                                                    relatedBy: .equal,
                                                    toItem: button,
                                                    attribute: .width,
                                                    multiplier: 1,
                                                    constant: 0)
        subtitleConstraint.isActive = true
        
        return subVStack
    }
    
    // 按钮点击处理程序
    @objc func buttonTapped(sender: DatePatternButton) {
        NotificationCenter.default.post(name: .dateFieldTapped, object: nil, userInfo: ["sender": sender.pattern])
    }
    
}
// 日期字段结构体
extension Notification.Name {
    static let dateFieldTapped = Notification.Name("dateFieldTapped")
}
