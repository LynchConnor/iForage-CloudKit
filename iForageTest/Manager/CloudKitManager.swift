//
//  CloudKitManager.swift
//  iForageTest
//
//  Created by Connor A Lynch on 25/11/2021.
//
import CloudKit
import Foundation
import SwiftUI

let container = CKContainer.init(identifier: "iCloud.iForage")

class CloudKitUtility {
    
    static func fetchRecords(query: CKQuery) async throws -> [CKRecord] {
        let (matchedRecords, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchedRecords.compactMap { _, value in try? value.get() }
        return records
    }
    
    static func modifyRecords(records: [CKRecord]) async throws {
        let (_, _) = try await container.publicCloudDatabase.modifyRecords(saving: records, deleting: [])
    }
    
    static func deleteRecord(recordID: CKRecord.ID) async throws {
        try await container.publicCloudDatabase.deleteRecord(withID: recordID)
    }
    
    static func saveRecord(record: CKRecord) async throws {
        try await container.publicCloudDatabase.save(record)
    }
    
    static func fetchRecord(recordID: CKRecord.ID) async throws -> CKRecord {
        return try await container.publicCloudDatabase.record(for: recordID)
    }
    
    static func fetchCurrentUserID() async throws -> CKRecord.ID {
        return try await container.userRecordID()
    }
}

extension CloudKitManager {
    enum ProfileState {
        case loading
        case signedIn
        case signedOut
    }
}

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    @Published var currentUserID: CKRecord.ID?
    @Published var currentUser: CKRecord?
    
    @Published var state: ProfileState = .loading
    
    @MainActor func fetchCurrentUser() async {
        self.state = .loading
        do {
            let id = try await CloudKitUtility.fetchCurrentUserID()
            self.currentUserID = id
            self.state = .signedIn
        }catch let error {
            print("DEBUG: \(error.localizedDescription)")
            self.state = .signedOut
        }
    }
    
    @MainActor func saveRecord(record: CKRecord) async throws {
        
        guard let id = currentUserID else { return }
        
        record[Post.kUserID] = CKRecord.Reference(recordID: id, action: .none)
        
        try await CloudKitUtility.saveRecord(record: record)
    }
    
    @MainActor func fetchPosts() async throws -> [Post] {
        
        guard let id = currentUserID else { return [] }
        
        let predicate = NSPredicate(format: "userID == %@", id)
        let query = CKQuery(recordType: RecordType.post, predicate: predicate)
        let records = try await CloudKitUtility.fetchRecords(query: query)
        return records.map(Post.init)
    }
    
    @MainActor func favouritePost() async throws {
        
    }
}
