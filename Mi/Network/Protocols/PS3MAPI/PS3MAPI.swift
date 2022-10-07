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
        return SyncServiceImpl.shared.getSocket(feat: Feature.ps3mapi())
    }
    
    func getFirmwareVersion() -> String? {
        let cmd = PS3MapiCommands.getfwversion.rawValue
        let response = sendCommand(cmd: cmd)
        let str = response?.response ?? "0"
        let ver = Int(str) ?? 0
        var string3 = String(ver, radix: 16, uppercase: true)
        string3.insert(".", at: String.Index(encodedOffset: 1))
        return string3
    }
    
    func getFirmwareType() -> String? {
        let cmd = PS3MapiCommands.getfwtype.rawValue
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    
    func getVersion() -> String? {
        let cmd = PS3MapiCommands.getversion.rawValue
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    
    func getMinVersion() -> String? {
        let cmd = PS3MapiCommands.getminversion.rawValue
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    
    func buzz(mode: Int) -> String? {
        let cmd = "\(PS3MapiCommands.buzzer.rawValue)\(mode)"
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    func reboot() -> String? {
        let cmd = "\(PS3MapiCommands.reboot.rawValue)"
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    func shutdown() -> String? {
        let cmd = "\(PS3MapiCommands.shutdown.rawValue)"
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    func softboot() -> String? {
        let cmd = "\(PS3MapiCommands.softboot.rawValue)"
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    func hardboot() -> String? {
        let cmd = "\(PS3MapiCommands.hardboot.rawValue)"
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    
    func getTemperature() -> Temperature? {
        let cmd = "\(PS3MapiCommands.temperature.rawValue)"
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
        let cmd = "\(PS3MapiCommands.psid.rawValue)"
        let result = sendCommand(cmd: cmd)
        return result?.response
    }
    
    func getIDPS() -> String? {
        let cmd = "\(PS3MapiCommands.idps.rawValue)"
        let result = sendCommand(cmd: cmd)
        return result?.response
    }
    
    func disconnect() -> String? {
        let cmd = "\(PS3MapiCommands.disconnect.rawValue)"
        let result = sendCommand(cmd: cmd)
        return result?.response
    }
    
    func notify(msg: String) -> String? {
        let cmd = "\(PS3MapiCommands.notify.rawValue) \(msg)"
        let response = sendCommand(cmd: cmd)
        return response?.response
    }
    
    func led(ledcolor: LedColor, mode: LedMode) -> String? {
        let cmd = "\(PS3MapiCommands.notify.rawValue) \(ledcolor.rawValue) \(mode.rawValue)"
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
