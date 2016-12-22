//
//  ISSAPI.swift
//  ISS Pager
//
//  Created by Nicolas Dedual on 12/21/16.
//  Copyright © 2016 Dedual Enterprises Inc. All rights reserved.
//

import Foundation
import Moya

private func JSONResponseDataFormatter(data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data, options: [])
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data //fallback to original data if it cant be serialized
    }
}


let endpointClosure = {(target:ISSAPI) -> Endpoint<ISSAPI> in
    
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    
    let endpoint:Endpoint<ISSAPI> = Endpoint<ISSAPI>(url: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
    
    return endpoint
    
}

struct ISSNetwork
{
    static let provider = MoyaProvider<ISSAPI>(endpointClosure:endpointClosure, plugins: [NetworkLoggerPlugin(verbose: false, responseDataFormatter: JSONResponseDataFormatter)])
    
    static func request(
        target: ISSAPI,
        success successCallback: @escaping (Any) -> Void,
        error errorCallback: @escaping (_ statusCode: Response) -> Void,
        failure failureCallback: @escaping (Moya.Error) -> Void
        )
    {
        provider.request(target, completion: { result in
            switch result {
            case let .success(response):
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                    let json = try response.mapJSON()
                    successCallback(json)
                }
                catch {
                    errorCallback(response)
                }
            case let .failure(error):
                
                failureCallback(error)
            }
            
        })
    }
}

enum ISSAPI
{
    case CurrentLocation()
    case PassTimes(lat:Double, lng:Double)
}

extension ISSAPI:TargetType
{
    var baseURL:URL {return URL(string:"http://api.open-notify.org")!}
    
    var path:String
    {
        switch self
        {
            
        case.CurrentLocation():
            return "/iss-now.json"
            
        case .PassTimes(_,_):
            return "/iss-pass.json"
            
        }
    }
    
    var method:Moya.Method
    {
        switch self
        {
            case .CurrentLocation, .PassTimes:
                return .get

        }
            
    }
    
    var parameters:[String:Any]?
    {
         switch self
         {
         case.CurrentLocation():
            return nil
            
         case .PassTimes(let lat, let lng):
            return ["lat":lat, "lon":lng]
        }
    }
    
    public var task: Task
    {
        switch self {
        case .CurrentLocation, .PassTimes:
            return .request
        }
    }
    
    var sampleData:Data
    {
        switch self
        {
        case.CurrentLocation():
            let returnString = "{\"timestamp\": 1482380125, \"message\": \"success\", \"iss_position\": {\"longitude\": \"-112.7691\", \"latitude\": \"-24.8663\"}}"
            
            return returnString.UTF8EncodedData

            
        case .PassTimes(_, _):
            
            let returnString = "{\"message\": \"success\",\"request\": {\"altitude\": 100,\"datetime\": 1482373586,\"latitude\":40.825133,\"longitude\": -73.9540127,\"passes\": 5},\"response\": [{\"duration\": 310,\"risetime\": 1482410637},{\"duration\": 626,\"risetime\": 1482416221},{\"duration\": 615,\"risetime\": 1482422021},{\"duration\": 552,\"risetime\": 1482427892},{\"duration\": 581,\"risetime\": 1482433727}]}"
            
            return returnString.UTF8EncodedData
        }
    }
}
