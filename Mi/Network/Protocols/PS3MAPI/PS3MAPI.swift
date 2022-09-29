//
//  PS3MAPI.swift
//  Mi
//
//  Created by Vonley on 9/28/22.
//

import Foundation
import Socket

protocol PS3MAPI {
    var socket: Socket? { get }
    
    func write(string: String) -> Bool
    func read() -> String?
    
}

class PS3MAPIImpl: PS3MAPI {
    
    var socket: Socket? {
        return SyncService.shared.getSocket(feat: Feature.ps3mapi())
    }
    
    func getFirmwareVersion() -> String? {
        let cmd = cmds.getfwversion.rawValue
        let response = sendCommand(cmd: cmd)
        let str = response?.response ?? "0"
        let ver = Int(str) ?? 0
        var string3 = String(ver, radix: 16, uppercase: true)
        string3.insert(".", at: String.Index(encodedOffset: 1))
        return string3
    }
    
    func getFirmwareType() -> String? {
        let cmd = cmds.getfwtype.rawValue
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    
    func getVersion() -> String? {
        let cmd = cmds.getversion.rawValue
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    
    func getMinVersion() -> String? {
        let cmd = cmds.getminversion.rawValue
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    
    func buzz(mode: Int) -> String? {
        let cmd = "\(cmds.buzzer.rawValue)\(mode)"
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    func reboot() -> String? {
        let cmd = "\(cmds.reboot.rawValue)"
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    func shutdown() -> String? {
        let cmd = "\(cmds.shutdown.rawValue)"
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    func softboot() -> String? {
        let cmd = "\(cmds.softboot.rawValue)"
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    func hardboot() -> String? {
        let cmd = "\(cmds.hardboot.rawValue)"
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    
    func getTemperature() -> Temperature? {
        let cmd = "\(cmds.temperature.rawValue)"
        if let result = sendCommand(cmd: cmd) {
            if (!result.response.contains(":")) {
                let temp = result.response.split(separator: "|")
                if(temp.count > 1){
                    return Temperature(cpu: String(temp[0]), rsx: String(temp[1]))
                }
                return nil
            }
        }
        return nil
    }
    
    func getPSID() -> String? {
        let cmd = "\(cmds.psid.rawValue)"
        let result = sendCommand(cmd: cmd)
        return result?.response
    }
    
    func getIDPS() -> String? {
        let cmd = "\(cmds.idps.rawValue)"
        let result = sendCommand(cmd: cmd)
        return result?.response
    }
    
    func disconnect() -> String? {
        let cmd = "\(cmds.disconnect.rawValue)"
        let result = sendCommand(cmd: cmd)
        return result?.response
    }
    
    func notify(msg: String) -> String? {
        let cmd = "\(cmds.notify.rawValue) \(msg)"
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    func led(ledcolor: ledcolor, mode: ledstatus) -> String? {
        let cmd = "\(cmds.notify.rawValue) \(ledcolor.rawValue) \(mode.rawValue)"
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    func getConsoleInfo() -> ConsoleInfo? {
        let fw = self.getFirmwareVersion()
        let type = self.getFirmwareType()
        let temp = self.getTemperature()
        if (fw != nil && type != nil && temp != nil) {
            return ConsoleInfo(firmware: fw!, type: ConsoleType.parse(type: type!), temp: temp!)
        }
        return nil
    }
    
    private func sendCommand(cmd: String) -> ps3mapi_response? {
        print("Sending Command")
        if (write(string: cmd + "\r\n")) {
            if let read = self.read() {
                print("res: \(read)")
                let parsed = ps3mapi_response.parse(response: read)
                return parsed
            } else{
                print("Could not read")
            }
        } else {
            print("Could not send command")
        }
        
        return nil
    }
    
    
    func write(string: String) -> Bool {
        if socket != nil {
            do {
                let bytesWritten = try socket!.write(from: string)
                print("Bytes: Written: \(bytesWritten)")
                return bytesWritten > 0
            } catch {
                print("Unable to write string: \(string) - \(error)")
            }
        } else {
            print("Socket is nil")
        }
        return false
    }
    
    func read() -> String? {
        if socket != nil {
            do {
                return try socket!.readString()
            } catch {
                print("Unable to read string: \(error)")
            }
        } else {
            print("Socket is nil")
        }
        return nil
    }
    
}
