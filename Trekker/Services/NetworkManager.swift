//
//  NetworkManager.swift
//  Trekker
//
//  Created by Cole M on 12/23/24.
//



protocol NetworkManagerDelegate: Sendable {
    func login() async
    func register() async
    func signInWithApple() async
    func logout() async
}

actor NetworkManager: NetworkManagerDelegate {
    func login() async {
        
    }
    
    func register() async {
        
    }
    
    func signInWithApple() async {
        
    }
    
    func logout() async {
        
    }

}
