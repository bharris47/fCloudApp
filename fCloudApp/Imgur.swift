//
//  Imgur.swift
//  fCloudApp
//
//  Created by Ben Harris on 5/13/15.
//  Copyright (c) 2015 Good Coode. All rights reserved.
//

import Foundation
import AFNetworking

struct ImgurCredentials {
    static let clientId = "23a43c33b42a59a"
    static let clientSecret = "2026e1d769e34f3803b39c2549d01940d72833ad"
}

struct Endpoints {
    static let image = "https://api.imgur.com/3/image"
    static let album = "https://api.imgur.com/3/album"
}

class Imgur {
    static func authorizeRequest(request: NSMutableURLRequest) {
        request.addValue("Client-ID " + ImgurCredentials.clientId, forHTTPHeaderField: "Authorization")
    }

    static func imageMultipartRequest(bodyBuilder: (AFMultipartFormData! -> Void)) -> NSMutableURLRequest {
        return Imgur.imageMultipartRequest(nil, bodyBuilder: bodyBuilder)
    }
    
    static func imageMultipartRequest(params: [String:String]?, bodyBuilder: (AFMultipartFormData! -> Void)) -> NSMutableURLRequest {
        let serializer = AFHTTPRequestSerializer()
        let request = serializer.multipartFormRequestWithMethod("POST",
            URLString: Endpoints.image,
            parameters: params,
            constructingBodyWithBlock: { (data: AFMultipartFormData!) in bodyBuilder(data) },
            error: nil
        )
        
        authorizeRequest(request)
        return request
    }
    
    static func albumRequest() -> NSMutableURLRequest {
        let serializer = AFHTTPRequestSerializer()
        let request = serializer.requestWithMethod("POST", URLString: Endpoints.album, parameters: nil, error: nil)        
        authorizeRequest(request)
        return request
    }
    
    static func urlForAlbum(albumId: String) -> String {
        return "http://imgur.com/a/\(albumId)"
    }
}