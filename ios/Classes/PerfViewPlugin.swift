import Flutter
import UIKit
import Foundation

public class PerfViewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "perf_view", binaryMessenger: registrar.messenger())
    let instance = PerfViewPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getNetworkInfo":
        let array: [Any] = [0,0]
        result(array)
    case "getMemoryInfo":
        let memoryTotal: Int = getMemorySize() / 1024
        // let memoryFree: UInt64? = getFreeMemory()
        var answer: [Any] = [memoryTotal,0]
        // if memoryFree != nil{
        //     answer[1] = memoryFree
        // }
        result(answer)
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getMemorySize() -> Int{
      let memory : Int = Int(ProcessInfo.processInfo.physicalMemory)
      let constant : Int = 1_048_576
      let total = memory / constant
      return Int(total)
  }

//   private func getAvailMemory() -> Int{
//       let memory : Int = Int(ProcessInfo.processInfo.physicalMemory)
//       let constant : Int = 1_048_576
//       let total = memory / constant
//       return Int(total)
//   }

//   func getFreeMemory() -> UInt64? {
//     var pagesize: vm_size_t = 0
//     let host_port: mach_port_t = mach_host_self()
//     var host_size = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.size / MemoryLayout<integer_t>.size)
//     host_page_size(host_port, &pagesize)
//     var vm_stat: vm_statistics = 
//     // var vm_stat: vm_statistics_data_t = vm_statistics
//     if host_statistics(host_port, HOST_VM_INFO, host_info_t(bitPattern: &vm_statistics_data_t), &host_size) != KERN_SUCCESS {
//         return nil
//     }
//     let mem_free = UInt64(vm_stat.free_count) * UInt64(pagesize)
//     return mem_free
// }

// if let freeMemory = getFreeMemory() {
//     print("Free memory available: \(freeMemory) bytes")
// }
}
