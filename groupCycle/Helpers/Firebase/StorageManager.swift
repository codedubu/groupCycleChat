//
//  StorageManager.swift
//  groupCycle
//
//  Created by River McCaine on 3/15/21.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    // MARK: - Properties
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>)
    
    // MARK: - Helper Methods
    /// Uploads picture to firebase storage and returns completion with URL string to download.
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping (UploadPictureCompletion) -> Void) {
        storage.child("images\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard let strongSelf = self else { return }
            
            guard error == nil else {
                //failed
                print("Failed to upload picture data to Firebase.")
                completion(.failure(StorageErrors.failedToUplaod))
                return
            }
            
            strongSelf.storage.child("images\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download URL")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download URL returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
    let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure((StorageErrors.failedToGetDownloadURL)))
                return
            }
            let urlString = url.absoluteString
            print("Download url returned: \(urlString)")
            completion(.success(url))
        })
    }
    
} // END OF CLASS
