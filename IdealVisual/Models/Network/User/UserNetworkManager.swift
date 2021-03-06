//
//  UserNetworkManager.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import Alamofire

final class UserNetworkManager: UserNetworkManagerProtocol {
    func create(newUser: JsonUserModel, completion: ((JsonUserModel?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.accountURL else {
            Logger.log("invalid create url: '\(String(describing: NetworkURLS.accountURL))'")
            return
        }

        AF.request(url, method: .post, parameters: newUser, encoder: JSONParameterEncoder(encoder: JSONEncoder()),
                   headers: [.accept(MimeTypes.appJSON)])
            .validate(contentType: [MimeTypes.appJSON])
            .responseData { response in
                if let error = response.error {
                    if let err = error.underlyingError as? URLError, err.code == URLError.Code.notConnectedToInternet {
                        completion?(nil, NetworkError(name: ErrorsNetwork.noConnection))
                    } else {
                        Logger.log("unknown error: \(error.localizedDescription)")
                        completion?(nil, NetworkError(name: error.localizedDescription))
                    }
                    return
                }

                if let status = response.response?.statusCode {
                    switch status {
                    case HTTPCodes.okay:
                        break
                    case HTTPCodes.unprocessableEntity:
                        guard let data = response.value else {
                            completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                            return
                        }
                        do {
                            let errors = try JSONDecoder().decode(JsonError.self, from: data)
                            completion?(nil, NetworkError(name: ErrorsNetwork.wrongFields, description: errors.errors))
                        } catch let error {
                            Logger.log("unknown network error: \(error.localizedDescription)")
                            completion?(nil, NetworkError(name: error.localizedDescription))
                        }
                        return
                    default:
                        Logger.log("unknown status code: \(status))")
                        completion?(nil, NetworkError(name: "unknown status code: \(status)"))
                        return
                    }
                }

                guard let data = response.value else {
                    completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                    return
                }

                do {
                    let user = try JSONDecoder().decode(JsonUserModel.self, from: data)
                    completion?(user, nil)
                } catch let error {
                    Logger.log("unknown network error: \(error.localizedDescription)")
                    completion?(nil, NetworkError(name: error.localizedDescription))
                }
        }.resume()
    }

    func login(user: JsonUserModel, completion: ((JsonUserModel?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.sessionURL else {
            Logger.log("invalid login url: '\(String(describing: NetworkURLS.sessionURL))'")
            return
        }

        AF.request(url, method: .post, parameters: user, encoder: JSONParameterEncoder(encoder: JSONEncoder()),
                   headers: [.accept(MimeTypes.appJSON)])
            .validate(contentType: [MimeTypes.appJSON])
            .responseDecodable(of: JsonUserModel.self) { response in
                if let error = response.error {
                    if let status = response.response?.statusCode {
                        switch status {
                        case HTTPCodes.forbidden:
                            completion?(nil, NetworkError(name: ErrorsNetwork.forbidden))
                        default:
                            Logger.log("unknown staus code: \(status))")
                            completion?(nil, NetworkError(name: "unknown status code: \(status)"))
                        }
                        return
                    }

                    if let err = error.underlyingError as? URLError, err.code == URLError.Code.notConnectedToInternet {
                        completion?(nil, NetworkError(name: ErrorsNetwork.noConnection))
                    } else {
                        Logger.log("unknown error: \(error.localizedDescription)")
                        completion?(nil, NetworkError(name: error.localizedDescription))
                    }
                    return
                }

                guard let user = response.value else {
                    Logger.log("data error: \(ErrorsNetwork.noData)")
                    completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                    return
                }
                completion?(user, nil)
        }.resume()
    }

    func update(token: String, user: JsonUserModel, completion: ((JsonUserModel?, NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.accountURL else {
            Logger.log("invalid update url: '\(String(describing: NetworkURLS.accountURL))'")
            return
        }

        AF.request(url, method: .put, parameters: user, encoder: JSONParameterEncoder(encoder: JSONEncoder()),
                   headers: [.accept(MimeTypes.appJSON), .authorization(bearerToken: token)])
            .validate(contentType: [MimeTypes.appJSON])
            .responseData { response in
                if let error = response.error {
                    if let status = response.response?.statusCode {
                        switch status {
                        case HTTPCodes.unauthorized:
                            completion?(nil, NetworkError(name: ErrorsNetwork.unauthorized))
                            return
                        case HTTPCodes.notFound:
                            completion?(nil, NetworkError(name: ErrorsNetwork.notFound))
                            return
                        default:
                            Logger.log("unknown staus code: \(status))")
                            completion?(nil, NetworkError(name: "unknown status code: \(status)"))
                            return
                        }
                    }

                    if let err = error.underlyingError as? URLError, err.code == URLError.Code.notConnectedToInternet {
                        completion?(nil, NetworkError(name: ErrorsNetwork.noConnection))
                    } else {
                        Logger.log("unknown error: \(error.localizedDescription)")
                        completion?(nil, NetworkError(name: error.localizedDescription))
                    }
                    return
                }

                if let status = response.response?.statusCode {
                    switch status {
                    case HTTPCodes.okay:
                        break
                    case HTTPCodes.unprocessableEntity:
                        guard let data = response.value else {
                            Logger.log("data error: \(ErrorsNetwork.noData)")
                            completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                            return
                        }
                        do {
                            let errors = try JSONDecoder().decode(JsonError.self, from: data)
                            completion?(nil, NetworkError(name: ErrorsNetwork.wrongFields,
                                                          description: errors.errors))
                        } catch let error {
                            Logger.log("unknown network error: \(error.localizedDescription)")
                            completion?(nil, NetworkError(name: error.localizedDescription))
                        }
                        return
                    default:
                        Logger.log("unknown staus code: \(status))")
                        completion?(nil, NetworkError(name: "unknown status code: \(status)"))
                        return
                    }
                }

                guard let data = response.value else {
                    Logger.log("data error: \(ErrorsNetwork.noData)")
                    completion?(nil, NetworkError(name: ErrorsNetwork.noData))
                    return
                }

                do {
                    let user = try JSONDecoder().decode(JsonUserModel.self, from: data)
                    completion?(user, nil)
                } catch let error {
                    Logger.log("unknown network error: \(error.localizedDescription)")
                    completion?(nil, NetworkError(name: error.localizedDescription))
                }
        }.resume()
    }

    func logout(token: String, completion: ((NetworkError?) -> Void)?) {
        guard let url = NetworkURLS.sessionURL else {
            Logger.log("invalid login url: '\(String(describing: NetworkURLS.sessionURL))'")
            return
        }

        AF.request(url, method: .delete, headers: [.authorization(bearerToken: token)])
            .response { response in
                if let error = response.error {
                    if let err = error.underlyingError as? URLError, err.code == URLError.Code.notConnectedToInternet {
                        completion?(NetworkError(name: ErrorsNetwork.noConnection))
                    } else {
                        Logger.log("unknown error: \(error.localizedDescription)")
                        completion?(NetworkError(name: error.localizedDescription))
                    }
                    return
                }

                if let status = response.response?.statusCode {
                    switch status {
                    case HTTPCodes.okay:
                        completion?(nil)
                    default:
                        Logger.log("unknown status code: \(status)")
                        completion?(NetworkError(name: "unknown status code: \(status)"))
                    }
                }
        }.resume()
    }
}
