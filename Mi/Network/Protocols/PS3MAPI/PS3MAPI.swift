//
//  PS3MAPI.swift
//  Mi
//
//  Created by Vonley on 9/28/22.
//

import Foundation
import Socket

protocol PS3MAPI {
    func socket() async -> Socket?
    
    func write(string: String) async -> Bool
    func read() async -> String?
    
}

class PS3MAPIImpl: PS3MAPI {
    
    func socket() async -> Socket? {
        return await SyncServiceImpl.shared.getSocket(feat: Feature.ps3mapi)
    }
    
    func getFirmwareVersion() async -> String?  {
        let cmd = PS3MapiCommands.getfwversion.rawValue
        let response = await sendCommand(cmd: cmd)
        let str = response?.response ?? "0"
        let ver = Int(str) ?? 0
        var string3 = String(ver, radix: 16, uppercase: true)
        string3.insert(".", at: String.Index(encodedOffset: 1))
        return string3
    }
    
    func getFirmwareType() async -> String? {
        let cmd = PS3MapiCommands.getfwtype.rawValue
        let response = await sendCommand(cmd: cmd)
        return response?.response
    }
    
    
    func getVersion() async -> String? {
        let cmd = PS3MapiCommands.getversion.rawValue
        let response = await sendCommand(cmd: cmd)
        return response?.response
    }
    
    
    func getMinVersion() async -> String? {
        let cmd = PS3MapiCommands.getminversion.rawValue
        let response = await sendCommand(cmd: cmd)
        return response?.response
    }
    
    
    func buzz(mode: Int) async -> String? {
        let cmd = "\(PS3MapiCommands.buzzer.rawValue)\(mode)"
        let response = await sendCommand(cmd: cmd)
        return response?.response
    }
    
    func reboot() async -> String? {
        let cmd = "\(PS3MapiCommands.reboot.rawValue)"
        let response = await sendCommand(cmd: cmd)
        return response?.response
    }
    
    func shutdown() async -> String? {
        let cmd = "\(PS3MapiCommands.shutdown.rawValue)"
        let response = await sendCommand(cmd: cmd)
        return response?.response
    }
    
    func softboot() async -> String? {
        let cmd = "\(PS3MapiCommands.softboot.rawValue)"
        let response = await sendCommand(cmd: cmd)
        return response?.response
    }
    
    func hardboot() async -> String? {
        let cmd = "\(PS3MapiCommands.hardboot.rawValue)"
        let response = await sendCommand(cmd: cmd)
        return response?.response
    }
    
    
    func getTemperature() async -> Temperature? {
        let cmd = "\(PS3MapiCommands.temperature.rawValue)"
        if let result = await sendCommand(cmd: cmd) {
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
    
    func getPSID() async -> String? {
        let cmd = "\(PS3MapiCommands.psid.rawValue)"
        let result = await sendCommand(cmd: cmd)
        return result?.response
    }
    
    func getIDPS() async -> String? {
        let cmd = "\(PS3MapiCommands.idps.rawValue)"
        let result = await sendCommand(cmd: cmd)
        return result?.response
    }
    
    func disconnect() async -> String? {
        let cmd = "\(PS3MapiCommands.disconnect.rawValue)"
        let result = await sendCommand(cmd: cmd)
        return result?.response
    }
    
    func notify(msg: String) async-> String? {
        let cmd = "\(PS3MapiCommands.notify.rawValue) \(msg)"
        let response = await sendCommand(cmd: cmd)
        return response?.response
    }
    
    func led(ledcolor: LedColor, mode: LedMode) async -> String? {
        let cmd = "\(PS3MapiCommands.notify.rawValue) \(ledcolor.rawValue) \(mode.rawValue)"
        let response = await sendCommand(cmd: cmd)
        return response?.response
    }
    
    func getConsoleInfo() async -> ConsoleInfo? {
        let fw = await self.getFirmwareVersion()
        let type = await self.getFirmwareType()
        let temp = await self.getTemperature()
        if (fw != nil && type != nil && temp != nil) {
            return ConsoleInfo(firmware: fw!, type: ConsoleType.parse(type: type!), temp: temp!)
        }
        return nil
    }
    
    private func sendCommand(cmd: String) async -> ps3mapi_response? {
        print("Sending Command")
        if (await write(string: cmd + "\r\n")) {
            if let read = await self.read() {
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
    
    
    func write(string: String) async -> Bool {
        if let socket = await socket() {
            do {
                let bytesWritten = try socket.write(from: string)
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
    
    func read() async -> String? {
        if let socket = await socket() {
            do {
                return try socket.readString()
            } catch {
                print("Unable to read string: \(error)")
            }
        } else {
            print("Socket is nil")
        }
        return nil
    }
    
}
