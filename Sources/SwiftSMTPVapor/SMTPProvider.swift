// SMTPProvider.swift
//

@_exported import SwiftSMTP
import Service

public struct SMTPProvider: Provider {
    public func register(_ services: inout Services) throws {
        services.register(Mailer.self)
    }

    public func didBoot(_ container: Container) throws -> Future<Void> {
        .done(on: container)
    }
    
    public init() { }
    
}
