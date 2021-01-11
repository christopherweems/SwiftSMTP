// SMTPErrors.swift
//

public struct MalformedSMTPMessageError: Error, CustomStringConvertible {
    public var description: String {
        "The message from the server was malformed!"
    }
    
}

public struct ServerError: Error, CustomStringConvertible {
    public let serverMessage: String
    
    public var description: String {
        "Received an error from the server: \(serverMessage)"
    }
    
}
