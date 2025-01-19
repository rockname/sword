import Foundation

extension String {
  var isFile: Bool {
    if isEmpty { return false }

    var isDirectoryObjC: ObjCBool = false
    if FileManager.default.fileExists(atPath: self, isDirectory: &isDirectoryObjC) {
      return !isDirectoryObjC.boolValue
    }

    return false
  }
}
