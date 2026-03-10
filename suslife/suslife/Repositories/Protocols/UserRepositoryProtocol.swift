//
//  UserRepositoryProtocol.swift
//  suslife
//
//  User Repository Protocol
//

import Foundation

protocol UserRepositoryProtocol {
    func getUserProfile() async throws -> UserProfile
    func updateStreak(_ streak: Int32) async throws
    func incrementActivityCount() async throws
    func save() async throws
}
