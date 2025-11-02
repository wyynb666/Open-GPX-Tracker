import Foundation
import CoreGPX


protocol GPXFilesTableViewControllerDelegate: AnyObject {

    ///
    /// 调用此方法后，GPXFilesTableView 控制器将被关闭
    ///
    /// - Parameters:
    ///       - gpxFile: 要加载的文件名，不带扩展名
    ///       - gpxRoot: 一个对象
    ///
    func didLoadGPXFileWithName(_ gpxFilename: String, gpxRoot: GPXRoot)
    
}
