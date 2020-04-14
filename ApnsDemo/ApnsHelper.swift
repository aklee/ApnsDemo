//
//  ApnsVoiceHelper.swift
//  ApnsDemo
//
//  Created by ak on 2020/4/14.
//  Copyright © 2020 ak. All rights reserved.
//

import UIKit

fileprivate let GroupName = "group.ent.com.aklee.demo"
struct ApnsHelper {
  
  static func makeMp3(_ cnt: Double) -> String {
    let path = NSHomeDirectory()+"/Library/Sounds/"
    return mergeVoice(libPath: path, cnt)
  }
  
  static func makeMp3FromExt(_ cnt: Double) -> String {
    let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GroupName)!.absoluteString.replacingOccurrences(of: "file://", with: "") + "Library/Sounds/"
    return mergeVoice(libPath: path, cnt)
  }
  
  private static func mergeVoice(libPath: String, _ cnt: Double) -> String {
    clearFiles(libPath)
    var nums = [String]()
    var tmp = Int(cnt)
    while(tmp>0) {
      nums.insert("\(tmp % 10)", at: 0)
      tmp = Int(tmp/10)
    }
    
    var mergeData = Data()
    nums.forEach { num in
      let mp3Url = Bundle.main.url(forResource: "tip.mp3", withExtension: "")//todo: 资源替换
      if let mp3Url = mp3Url, let data = try? Data(contentsOf: mp3Url) {
        mergeData.append(data)
      }
    }
    guard !mergeData.isEmpty else { return "" }
    if !FileManager.default.fileExists(atPath: libPath) {
      do {
        try FileManager.default.createDirectory(atPath: libPath, withIntermediateDirectories: true, attributes: nil)
      } catch {
        NSLog("创建Sounds文件失败 \(libPath)")
      }
    }
    let fileName = "\(now()).mp3"
    let fileUrl = URL(string: "file://\(libPath)\(fileName)")
    guard let url = fileUrl else { return "" }
    do {
      try mergeData.write(to: url)
    } catch {
      NSLog("合成mp3文件失败 \(url)")
    }
    return fileName
  }
  
  private static func clearFiles(_ libPath: String) {
    var isDir: ObjCBool = false
    guard FileManager.default.fileExists(atPath: libPath, isDirectory: &isDir), let list = try? FileManager.default.contentsOfDirectory(atPath: libPath) else { return }
    let before = now() - 12*60*60*1000 //1day ago
    list.forEach { file in
      if let time = Int(file.replacingOccurrences(of: ".mp3", with: "")), time < before {
        //delete file
        do {
          try FileManager.default.removeItem(at: URL(string: "file://" + libPath + file)!)
        } catch {
          NSLog("删除过期mp3失败")
        }
      }
    }
  }
  
  private static func now() -> Int {
    return Int(Date().timeIntervalSince1970*1000)
  }
}
