//
//  PS3MAPI+Enums.swift
//  Mi
//
//  Created by Vonley on 9/28/22.
//

import Foundation

/**
 *   PS3MAPI Socket Commands
 *   These are the basic commands for ps3mapi protocols
 */
enum PS3MapiCommands: String {
    
    case getfwversion = "PS3 GETFWVERSION",
         getfwtype = "PS3 GETFWTYPE",
         getversion = "PS3 GETVERSION",
         getminversion = "PS3 GETMINVERSION",
         buzzer = "PS3 BUZZER", // PS3 BUZZER<0-9> // CONTINUOUS, SINGLE, DOUBLE, TRIPLE
         reboot = "PS3 REBOOT",
         shutdown = "PS3 SHUTDOWN",
         hardboot = "PS3 HARDBOOT",
         softboot = "PS3 SOFTBOOT",
         notify = "PS3 NOTIFY",
         led = "PS3 LED", // PS3 LED <colorOrderInt> <modeOrderInt>
         //RED, GREEN, YELLOW : OFF, ON, BLINK, BLINKSLOW
         idps = "PS3 GETIDPS",
         psid = "PS3 GETPSID",
         temperature = "PS3 GETTEMP",
         disconnect = "DISCONNECT",
         processes = "PROCESS GETALLPID"
    
}

enum ConsoleId {
    case idps, psid
}

enum LedColor: Int {
    case red = 0, green, yellow
}

enum LedMode: Int {
    case off = 0, on, blink, blinkslow
}

enum SysCall8mode {
    case enabled, only_cobra_mamba_and_ps3api_enabled,only_ps3api_enabled, fakedisabled, disabled
}


enum DeleteHistory {
    case EXCLUDE_DIR, INCLUDE_DIR
}


enum ps3mapi_code {
    case ps3mapi_ok_data_connection_already_open(code: Int = 125),
         ps3mapi_ok_memory_status(code: Int = 150, message: String = "Binary status okay; about to open connection."),
        ps3mapi_ok_successful_command(code: Int = 200, message: String = "The requested action has been successfully completed."),
        ps3mapi_ok_server_connecting(code: Int = 220, message: String = "PS3 Manager API Server v1."),
        ps3mapi_ok_service_closing_control(code: Int = 221, message: String = "Service closing control connection."),
        ps3mapi_ok_closing_data_connection(code: Int = 226, message: String = "Closing data connection. Requested binary action successful."),
        ps3mapi_ok_entering_passive_mode(code: Int = 227, message: String = ""),
        ps3mapi_ok_mgr_server_detected(code: Int = 230, message: String = "Connected to PS3 Manager API Server."),
        ps3mapi_ok_memory_action_completed(code: Int = 250),
        ps3mapi_ok_memory_action_pending(code: Int = 350),
        ps3mapi_error_425(code: Int = 425, message: String = "Can't open data connection."),
        ps3mapi_error_451(code: Int = 451, message: String = "Requested action aborted. Local error in processing."),
        ps3mapi_error_501(code: Int = 501, message: String = "Requested action not taken."),
        ps3mapi_error_502(code: Int = 502, message: String = "Syntax error in parameters"),
        ps3mapi_error_550(code: Int = 550, message: String = "Requested action not taken.")
}

extension ps3mapi_code: CaseIterable {
    
    static var allCases: [ps3mapi_code] {
        return [
            .ps3mapi_ok_data_connection_already_open(), .ps3mapi_ok_memory_status(), .ps3mapi_ok_successful_command(),
            .ps3mapi_ok_server_connecting(), .ps3mapi_ok_service_closing_control(), .ps3mapi_ok_closing_data_connection(),
            .ps3mapi_ok_entering_passive_mode(), .ps3mapi_ok_mgr_server_detected(), .ps3mapi_ok_memory_action_completed(),
            .ps3mapi_ok_memory_action_pending(),
            .ps3mapi_error_425(), .ps3mapi_error_451(), .ps3mapi_error_501(), .ps3mapi_error_502(), .ps3mapi_error_550()
        ]
    }
    
    private static func findResponse(value: Int) -> ps3mapi_code {
        for pcode in ps3mapi_code.allCases {
            switch pcode {
                
            case .ps3mapi_ok_data_connection_already_open(code: let code):
                if code == value {
                    return pcode
                }
                continue
            case .ps3mapi_ok_memory_status(code: let code, message: _):
                if code == value {
                    return pcode
                }
                continue
            case .ps3mapi_ok_successful_command(code: let code, message: _):
                if code == value {
                    return pcode
                }
                continue
            case .ps3mapi_ok_server_connecting(code: let code, message: _):
                if code == value {
                    return pcode
                }
                continue
            case .ps3mapi_ok_service_closing_control(code: let code, message: _):
                if code == value {
                    return pcode
                }
                continue
            case .ps3mapi_ok_closing_data_connection(code: let code, message: _):
                if code == value {
                    return pcode
                }
                continue
            case .ps3mapi_ok_entering_passive_mode(code: let code, message: _):
                if code == value {
                    return pcode
                }
                continue
            case .ps3mapi_ok_mgr_server_detected(code: let code, message: _):
                if code == value {
                    return pcode
                }
                continue
            case .ps3mapi_ok_memory_action_completed(code: let code):
                if code == value {
                    return pcode
                }
                continue
            case .ps3mapi_ok_memory_action_pending(code: let code):
                if code == value {
                    return pcode
                }
                continue
            case .ps3mapi_error_425(code: let code, message: _):
                if code == value {
                    return pcode
                }
                continue
            case .ps3mapi_error_451(code: let code, message: _):
                if code == value {
                    return pcode
                }
                continue
            case .ps3mapi_error_501(code: let code, message: _):
                if code == value {
                    return pcode
                }
                continue
            case .ps3mapi_error_502(code: let code, message: _):
                if code == value {
                    return pcode
                }
                continue
            case .ps3mapi_error_550(code: let code, message: _):
                if code == value {
                    return pcode
                }
                continue
            }
        }
        return ps3mapi_code.ps3mapi_error_550()
    }

    static func parseResponse(success: Bool, response: String) -> ps3mapi_response {
        if (success) {
            let responseCode = Int(
                response.substring(
                    to: String.Index(encodedOffset: 3)
                )
            )
            var buffer = response
                .substring(
                    from: String.Index(encodedOffset: 4)
                ).replacingOccurrences(of:"\r\n", with: "")
            if (buffer.contains("OK: ")) {
                buffer = buffer.replacingOccurrences(of: "OK: ",with: "")
            }
            return ps3mapi_response.create(success: success, response: buffer, code: findResponse(value: responseCode ?? 550))
        }
        return ps3mapi_response.create(success: success, response: response, code: ps3mapi_code.ps3mapi_error_550())
    }


}


extension PS3MapiCommands: Identifiable, CaseIterable {
    
    var id: String {
        return self.rawValue
    }
    
    var icon: String {
        switch(self) {
        case .idps:
            return "lock.circle"
        case .psid:
            return "lock.circle"
        case .notify:
            return "bubble.right.circle"
        case .processes:
            return "list.bullet.circle"
        case .temperature:
            return "sun.max.circle"
        default:
            return "gear"
        }
    }
    
    func getTitle() -> String {
        switch self {
        case .getfwversion:
            return "Get Firmware Version"
        case .getfwtype:
            return "Get Firmware Type"
        case .getversion:
            return "Get PS3 Manager Version"
        case .getminversion:
            return "Get PS3 Manager Min Compatible Version"
        case .buzzer:
            return "Buzz"
        case .reboot:
            return "Reboot"
        case .shutdown:
            return "Shutdown"
        case .hardboot:
            return "Hardboot"
        case .softboot:
            return "Softboot"
        case .notify:
            return "Notify"
        case .led:
            return "Led"
        case .idps:
            return "IDPS"
        case .psid:
            return "PSID"
        case .temperature:
            return "Temperature"
        case .disconnect:
            return "Disconnect"
        case .processes:
            return "Processes"
        }
    }
}
