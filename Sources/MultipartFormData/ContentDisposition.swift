//
//  ContentDisposition.swift
//  swift-multipart-formdata
//
//  Created by Felix Herrmann on 29.12.21.
//

import Foundation

/// A `Content-Disposition` header field of an HTTP request.
public struct ContentDisposition: HTTPHeaderField {
    
    public static let name: String = "Content-Disposition"
    
    public var value: String {
        return "form-data"
    }
    
    public var parameters: [HTTPHeaderParameter]
}

// MARK: - Percent Encoding

extension ContentDisposition {
    /// Represents an error for a name that can not be percent encoded.
    public struct PercentEncodingError: Error, CustomDebugStringConvertible {
        /// The initial value that could not be percent encoded.
        public var initialValue: String
        
        public var debugDescription: String {
            return "PercentEncodingError: \(initialValue) can not be percent-encoded!"
        }
    }
    
    /// Creates a new ``ContentDisposition`` object.
    ///
    /// This initializer ensures the correct encodings of the parameters.
    /// The ``parameters`` property can me modified but the `name` and `filename` elements should not be touched.
    ///
    /// - Throws: A ``PercentEncodingError`` if one of the names can not be percent encoded.
    ///
    /// - Parameters:
    ///   - name: The value for the `name` parameter.
    ///   - filename: The value for the optional `filename` parameter.
    ///   - encodeParameters: Flag that allow to enable/disable parameters encoding
    public init(uncheckedName name: String, uncheckedFilename filename: String? = nil, encodeParameters: Bool = true) throws {
        guard encodeParameters else {
            if let filename {
                parameters = [
                    HTTPHeaderParameter("name", value: name),
                    HTTPHeaderParameter("filename", value: filename)
                ]
            } else {
                parameters = [HTTPHeaderParameter("name", value: name)]
            }
            return
        }
        guard let percentEncodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw PercentEncodingError(initialValue: name)
        }
        if let filename {
            guard let percentEncodedFilename = filename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
                throw PercentEncodingError(initialValue: filename)
            }
            parameters = [
                HTTPHeaderParameter("name", value: percentEncodedName),
                HTTPHeaderParameter("filename", value: percentEncodedFilename)
            ]
        } else {
            parameters = [HTTPHeaderParameter("name", value: percentEncodedName)]
        }
    }
    
    /// Creates a new ``ContentDisposition`` object.
    ///
    /// It is not possible to create a `StaticString` that can not be percent encoded.
    /// Therefore, unlike ``init(uncheckedName:uncheckedFilename:)``, this initializer can not throw an error.
    ///
    /// This initializer ensures the correct encodings of the parameters.
    /// The ``parameters`` property can me modified but the `name` and `filename` elements should not be touched.
    ///
    /// - Parameters:
    ///   - name: The value for the `name` parameter.
    ///   - filename: The value for the optional `filename` parameter.
    ///   - encodeParameters: Flag that allow to enable/disable parameters encoding
    public init(name: StaticString, filename: StaticString? = nil, encodeParameters: Bool = true) {
        // swiftlint:disable:next force_try
        try! self.init(uncheckedName: String(name), uncheckedFilename: filename.map { String($0) }, encodeParameters: encodeParameters)
    }
}
