//
//  NetworkMonitor.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 21.01.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import Network

class NetworkMonitor {
    
    let monitor = NWPathMonitor()
    var isReachable: Bool { status == .satisfied }
    private var status: NWPath.Status = .requiresConnection
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.status = path.status
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
