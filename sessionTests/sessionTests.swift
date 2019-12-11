//
//  sessionTests.swift
//  sessionTests
//
//  Created by Nemi Shah on 20/09/19.
//  Copyright © 2019 SuperTokens. All rights reserved.
//
import Foundation
import XCTest

@testable import session

class sessionTests: XCTestCase {
    static let testAPIBase = "http://127.0.0.1:8080/"
    let refreshTokenAPIURL = "\(testAPIBase)refresh"
    let loginAPIURL = "\(testAPIBase)login"
    let userInfoAPIURL = "\(testAPIBase)userInfo"
    let logoutAPIURL = "\(testAPIBase)logout"
    let headerAPIURL = "\(testAPIBase)header"
    let refreshCounterAPIURL = "\(testAPIBase)refreshCounter"
    let sessionExpiryCode = 440
    

    override class func tearDown() {
        let semaphore = DispatchSemaphore(value: 0)
        afterAPI(successCallback: {
            semaphore.signal()
        }, failureCallback: {
            semaphore.signal()
        })
         _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        super.tearDown()
    }

    override func setUp() {
        super.setUp()
        SuperTokens.isInitCalled = false
        AntiCSRF.removeToken()
        IdRefreshToken.removeToken()
        
        let semaphore = DispatchSemaphore(value: 0)
        beforeEachAPI(successCallback: {
            semaphore.signal()
        }, failureCallback: {
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    func testThatRequestsFailIfInitIsNotCalled() {
        var failed = true
        let semaphore = DispatchSemaphore(value: 0)
        
        let url = URL(string: loginAPIURL)
        let request = URLRequest(url: url!)
        SuperTokensURLSession.newTask(request: request, completionHandler: {
            data, response, error in
            defer {
                semaphore.signal()
            }
            if error != nil {
                switch error! {
                    case SuperTokensError.illegalAccess("SuperTokens.init must be called before calling SuperTokensURLSession.newTask"):
                        failed = false
                        break
                    default:
                        break
                }
            }
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        XCTAssertTrue(!failed)
    }
    
    func testThatManualRefreshFailsIfInitIsNotCalled() {
        var failed = true
        let semaphore = DispatchSemaphore(value: 0)
        
        SuperTokensURLSession.attemptRefreshingSession(completionHandler: { result, error in
            defer {
                semaphore.signal()
            }
            
            if error != nil {
                switch error! {
                    case SuperTokensError.illegalAccess("SuperTokens.init must be called before calling SuperTokensURLSession.attemptRefreshingSession"):
                        failed = false
                        break
                    default:
                        break
                }
            }
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        XCTAssertTrue(!failed)
    }
    
    func testIfRefreshIsCalledAfterAccessTokenExpires() {
        startST(validity: 3)
        
        var failed = false
        do {
            try SuperTokens.`init`(refreshTokenEndpoint: refreshTokenAPIURL, sessionExpiryStatusCode: sessionExpiryCode)
        } catch {
            failed = true
        }
        
        let url = URL(string: loginAPIURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let requestSemaphore = DispatchSemaphore(value: 0)
        
        SuperTokensURLSession.newTask(request: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                failed = true
                requestSemaphore.signal()
                return
            }
            
            if response as? HTTPURLResponse != nil {
                let httpResponse = response as! HTTPURLResponse
                if httpResponse.statusCode != 200 {
                    failed = true
                    requestSemaphore.signal()
                } else {
                    let userInfoURL = URL(string: self.userInfoAPIURL)
                    let userInfoRequest = URLRequest(url: userInfoURL!)
                    
                    sleep(5)
                    
                    SuperTokensURLSession.newTask(request: userInfoRequest, completionHandler: {
                        userInfoData, userInfoResponse, userInfoError in
                        
                        if userInfoError != nil {
                            failed = true
                            requestSemaphore.signal()
                            return
                        }
                        
                        if userInfoResponse as? HTTPURLResponse != nil {
                            let userInfoHttpResponse = userInfoResponse as! HTTPURLResponse
                            if userInfoHttpResponse.statusCode != 200 {
                                failed = true
                            }
                            requestSemaphore.signal()
                        } else {
                            failed = true
                            requestSemaphore.signal()
                        }
                    })
                }
            } else {
                failed = true
                requestSemaphore.signal()
            }
        })
        
        _ = requestSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        let counter = getRefreshTokenCounter()
        if (counter != 1) {
            failed = true;
        }
        
        XCTAssertTrue(!failed)
    }
    
//    func testIfRefreshIsCalledIfAntiCSRFIsCleared() {
//        var failed = false
//        let resetSemaphore = DispatchSemaphore(value: 0)
//
////        resetAccessTokenValidity(validity: 10, failureCallback: {
////            failed = true
////            resetSemaphore.signal()
////        }, successCallback: {
////            resetSemaphore.signal()
////        })
//
//        _ = resetSemaphore.wait(timeout: DispatchTime.distantFuture)
//        let url = URL(string: loginAPIURL)
//        var request = URLRequest(url: url!)
//        request.httpMethod = "POST"
//        let requestSemaphore = DispatchSemaphore(value: 0)
//        do {
//            try SuperTokens.`init`(refreshTokenEndpoint: refreshTokenAPIURL, sessionExpiryStatusCode: sessionExpiryCode)
//            SuperTokensURLSession.newTask(request: request, completionHandler: {
//                data, response, error in
//
//                if error != nil {
//                    failed = true
//                    requestSemaphore.signal()
//                    return
//                }
//
//                if response as? HTTPURLResponse != nil {
//                    let httpResponse = response as! HTTPURLResponse
//                    if httpResponse.statusCode != 200 {
//                        failed = true
//                        requestSemaphore.signal()
//                    } else {
//                        let userInfoURL = URL(string: self.userInfoAPIURL)
//                        let userInfoRequest = URLRequest(url: userInfoURL!)
//
//                        AntiCSRF.removeToken()
//
//                        SuperTokensURLSession.newTask(request: userInfoRequest, completionHandler: {
//                            userInfoData, userInfoResponse, userInfoError in
//
//                            if userInfoError != nil {
//                                failed = true
//                                requestSemaphore.signal()
//                                return
//                            }
//
//                            if userInfoResponse as? HTTPURLResponse != nil {
//                                let userInfoHttpResponse = userInfoResponse as! HTTPURLResponse
//                                if userInfoHttpResponse.statusCode != 200 {
//                                    failed = true
//                                }
//                                requestSemaphore.signal()
//                            } else {
//                                failed = true
//                                requestSemaphore.signal()
//                            }
//                        })
//                    }
//                } else {
//                    failed = true
//                    requestSemaphore.signal()
//                }
//            })
//        } catch {
//            failed = true
//        }
//
//        _ = requestSemaphore.wait(timeout: DispatchTime.distantFuture)
//
//        let refreshCounterSemaphore = DispatchSemaphore(value: 0)
//        getRefreshTokenCounter(successCallback: {
//            counter in
//
//            if counter != 1 {
//                failed = true
//            }
//
//            refreshCounterSemaphore.signal()
//        }, failureCallback: {
//            failed = true
//            refreshCounterSemaphore.signal()
//        })
//        _ = refreshCounterSemaphore.wait(timeout: DispatchTime.distantFuture)
//
//        XCTAssertTrue(!failed)
//    }
//
//    func testThatRefreshIsCalledOnlyOnceForMultipleThreads() {
//        var failed = false
//
//        let resetSemaphore = DispatchSemaphore(value: 0)
//
////        resetAccessTokenValidity(validity: 10, failureCallback: {
////            failed = true
////            resetSemaphore.signal()
////        }, successCallback: {
////            resetSemaphore.signal()
////        })
//
//        _ = resetSemaphore.wait(timeout: DispatchTime.distantFuture)
//
//        let url = URL(string: loginAPIURL)
//        var request = URLRequest(url: url!)
//        request.httpMethod = "POST"
//        let requestSemaphore = DispatchSemaphore(value: 0)
//        let countSemaphore = DispatchSemaphore(value: 0)
//        var results: [Bool] = []
//
//        do {
//            try SuperTokens.`init`(refreshTokenEndpoint: refreshTokenAPIURL, sessionExpiryStatusCode: sessionExpiryCode)
//            SuperTokensURLSession.newTask(request: request, completionHandler: {
//                data, response, error in
//
//                if error != nil {
//                    failed = true
//                    requestSemaphore.signal()
//                    return
//                }
//
//                if response as? HTTPURLResponse != nil {
//                    let httpResponse = response as! HTTPURLResponse
//                    if httpResponse.statusCode != 200 {
//                        failed = true
//                        requestSemaphore.signal()
//                    } else {
//                        let userInfoURL = URL(string: self.userInfoAPIURL)
//                        let userInfoRequest = URLRequest(url: userInfoURL!)
//                        var runnables: [() -> ()] = []
//                        let runnableCount = 100
//                        let resultsLock = NSObject()
//
//                        for _ in 1...runnableCount {
//                            runnables.append {
//                                SuperTokensURLSession.newTask(request: userInfoRequest, completionHandler: {
//                                    userInfoData, userInfoResponse, userInfoError in
//
//                                    defer {
//                                        if results.count == runnableCount {
//                                            requestSemaphore.signal()
//                                        }
//                                    }
//
//                                    if userInfoResponse as? HTTPURLResponse != nil {
//                                        let userInfoHttpResponse = userInfoResponse as! HTTPURLResponse
//                                        var success = false
//                                        if userInfoHttpResponse.statusCode == 200 {
//                                            success = true
//                                        }
//                                        objc_sync_enter(resultsLock)
//                                        results.append(success)
//                                        objc_sync_exit(resultsLock)
//                                    } else {
//                                        objc_sync_enter(resultsLock)
//                                        results.append(false)
//                                        objc_sync_exit(resultsLock)
//                                    }
//                                })
//                            }
//                        }
//
//                        sleep(10)
//
//                        runnables.forEach({
//                            runnable in
//                            runnable()
//                        })
//                    }
//                } else {
//                    failed = true
//                    requestSemaphore.signal()
//                }
//            })
//        } catch {
//            failed = true
//        }
//
//        _ = requestSemaphore.wait(timeout: DispatchTime.distantFuture)
//
//        if results.contains(false) {
//            failed = true
//        } else {
//            let refreshCounterSemaphore = DispatchSemaphore(value: 0)
//            getRefreshTokenCounter(successCallback: {
//                counter in
//
//                if counter != 1 {
//                    failed = true
//                }
//
//                refreshCounterSemaphore.signal()
//            }, failureCallback: {
//                failed = true
//                refreshCounterSemaphore.signal()
//            })
//            _ = refreshCounterSemaphore.wait(timeout: DispatchTime.distantFuture)
//        }
//
//        XCTAssertTrue(!failed)
//    }
//
//    func testThatSessionPossibleExistsIsFalseAfterLogout() {
//        var failed = false
//
//        let resetSemaphore = DispatchSemaphore(value: 0)
//
////        resetAccessTokenValidity(validity: 10, failureCallback: {
////            failed = true
////            resetSemaphore.signal()
////        }, successCallback: {
////            resetSemaphore.signal()
////        })
//
//        _ = resetSemaphore.wait(timeout: DispatchTime.distantFuture)
//
//        let url = URL(string: loginAPIURL)
//        var request = URLRequest(url: url!)
//        request.httpMethod = "POST"
//        let requestSemaphore = DispatchSemaphore(value: 0)
//
//        do {
//            try SuperTokens.`init`(refreshTokenEndpoint: refreshTokenAPIURL, sessionExpiryStatusCode: sessionExpiryCode)
//            SuperTokensURLSession.newTask(request: request, completionHandler: {
//                data, response, error in
//
//                if error != nil {
//                    failed = true
//                    requestSemaphore.signal()
//                    return
//                }
//
//                if response as? HTTPURLResponse != nil {
//                    let httpResponse = response as! HTTPURLResponse
//                    if httpResponse.statusCode != 200 {
//                        failed = true
//                        requestSemaphore.signal()
//                    } else {
//                        let logoutURL = URL(string: self.logoutAPIURL)!
//                        var logoutRequest = URLRequest(url: logoutURL)
//                        logoutRequest.httpMethod = "POST"
//                        SuperTokensURLSession.newTask(request: logoutRequest, completionHandler: {
//                            logoutData, logoutResponse, logoutError in
//
//                            if logoutError != nil {
//                                failed = true
//                                requestSemaphore.signal()
//                                return
//                            }
//
//                            if logoutResponse as? HTTPURLResponse != nil {
//                                let httpLogoutResponse = logoutResponse as! HTTPURLResponse
//                                if httpLogoutResponse.statusCode != 200 {
//                                    failed = true
//                                    requestSemaphore.signal()
//                                    return
//                                }
//
//                                let isSessionActive = SuperTokens.sessionPossiblyExists()
//                                if isSessionActive {
//                                    failed = true
//                                }
//                                requestSemaphore.signal()
//                            } else {
//                                failed = true
//                                requestSemaphore.signal()
//                            }
//                        })
//                    }
//                } else {
//                    failed = true
//                    requestSemaphore.signal()
//                }
//            })
//        } catch {
//            failed = true
//        }
//
//        _ = requestSemaphore.wait(timeout: DispatchTime.distantFuture)
//        XCTAssertTrue(!failed)
//    }
//
//    func testThatAPIWithoutAuthSucceedAfterLogout() {
//        var failed = false
//
//        let resetSemaphore = DispatchSemaphore(value: 0)
//
////        resetAccessTokenValidity(validity: 10, failureCallback: {
////            failed = true
////            resetSemaphore.signal()
////        }, successCallback: {
////            resetSemaphore.signal()
////        })
//
//        _ = resetSemaphore.wait(timeout: DispatchTime.distantFuture)
//
//        let url = URL(string: loginAPIURL)
//        var request = URLRequest(url: url!)
//        request.httpMethod = "POST"
//        let requestSemaphore = DispatchSemaphore(value: 0)
//
//        do {
//            try SuperTokens.`init`(refreshTokenEndpoint: refreshTokenAPIURL, sessionExpiryStatusCode: sessionExpiryCode)
//
//            SuperTokensURLSession.newTask(request: request, completionHandler: {
//                data, response, error in
//
//                if error != nil {
//                    failed = true
//                    requestSemaphore.signal()
//                    return
//                }
//
//                if response as? HTTPURLResponse != nil {
//                    let httpResponse = response as! HTTPURLResponse
//                    if httpResponse.statusCode != 200 {
//                        failed = true
//                        requestSemaphore.signal()
//                    } else {
//                        let logoutURL = URL(string: self.logoutAPIURL)!
//                        var logoutRequest = URLRequest(url: logoutURL)
//                        logoutRequest.httpMethod = "POST"
//                        SuperTokensURLSession.newTask(request: logoutRequest, completionHandler: {
//                            logoutData, logoutResponse, logoutError in
//
//                            if logoutError != nil {
//                                failed = true
//                                requestSemaphore.signal()
//                                return
//                            }
//
//                            if logoutResponse as? HTTPURLResponse != nil {
//                                let httpLogoutResponse = logoutResponse as! HTTPURLResponse
//                                if httpLogoutResponse.statusCode != 200 {
//                                    failed = true
//                                    requestSemaphore.signal()
//                                    return
//                                }
//
//                                let refreshCounterURL = URL(string: self.refreshCounterAPIURL)
//                                let refreshCounterRequest = URLRequest(url: refreshCounterURL!)
//
//                                SuperTokensURLSession.newTask(request: refreshCounterRequest, completionHandler: {
//                                    refreshCounterData, refreshCounterResponse, refreshCounterError in
//
//                                    if refreshCounterError != nil {
//                                        failed = true
//                                        requestSemaphore.signal()
//                                        return
//                                    }
//
//                                    if refreshCounterResponse as? HTTPURLResponse != nil {
//                                        let refereshCounterHttpResponse = refreshCounterResponse as! HTTPURLResponse
//                                        if refereshCounterHttpResponse.statusCode != 200 {
//                                            failed = true
//                                        }
//                                        requestSemaphore.signal()
//                                    } else {
//                                        failed = true
//                                        requestSemaphore.signal()
//                                    }
//                                })
//
//                                requestSemaphore.signal()
//                            } else {
//                                failed = true
//                                requestSemaphore.signal()
//                            }
//                        })
//                    }
//                } else {
//                    failed = true
//                    requestSemaphore.signal()
//                }
//            })
//        } catch {
//            failed = true
//        }
//
//        _ = requestSemaphore.wait(timeout: DispatchTime.distantFuture)
//        XCTAssertTrue(!failed)
//    }
//
//    func testThatUserInfoAfterLogoutReturnsSessionExpiry() {
//        var failed = false
//
//        let resetSemaphore = DispatchSemaphore(value: 0)
//
////        resetAccessTokenValidity(validity: 10, failureCallback: {
////            failed = true
////            resetSemaphore.signal()
////        }, successCallback: {
////            resetSemaphore.signal()
////        })
//
//        _ = resetSemaphore.wait(timeout: DispatchTime.distantFuture)
//
//        let url = URL(string: loginAPIURL)
//        var request = URLRequest(url: url!)
//        request.httpMethod = "POST"
//        let requestSemaphore = DispatchSemaphore(value: 0)
//
//        do {
//            try SuperTokens.`init`(refreshTokenEndpoint: refreshTokenAPIURL, sessionExpiryStatusCode: sessionExpiryCode)
//            SuperTokensURLSession.newTask(request: request, completionHandler: {
//                data, response, error in
//
//                if error != nil {
//                    failed = true
//                    requestSemaphore.signal()
//                    return
//                }
//
//                if response as? HTTPURLResponse != nil {
//                    let httpResponse = response as! HTTPURLResponse
//                    if httpResponse.statusCode != 200 {
//                        failed = true
//                        requestSemaphore.signal()
//                    } else {
//                        let logoutURL = URL(string: self.logoutAPIURL)!
//                        var logoutRequest = URLRequest(url: logoutURL)
//                        logoutRequest.httpMethod = "POST"
//                        SuperTokensURLSession.newTask(request: logoutRequest, completionHandler: {
//                            logoutData, logoutResponse, logoutError in
//
//                            if logoutError != nil {
//                                failed = true
//                                requestSemaphore.signal()
//                                return
//                            }
//
//                            if logoutResponse as? HTTPURLResponse != nil {
//                                let httpLogoutResponse = logoutResponse as! HTTPURLResponse
//                                if httpLogoutResponse.statusCode != 200 {
//                                    failed = true
//                                    requestSemaphore.signal()
//                                    return
//                                }
//
//                                let userInfoURL = URL(string: self.userInfoAPIURL)
//                                let userInfoRequest = URLRequest(url: userInfoURL!)
//
//                                SuperTokensURLSession.newTask(request: userInfoRequest, completionHandler: {
//                                    userInfoData, userInfoResponse, userInfoError in
//
//                                    if userInfoError != nil {
//                                        failed = true
//                                        requestSemaphore.signal()
//                                        return
//                                    }
//
//                                    if userInfoResponse as? HTTPURLResponse != nil {
//                                        let userInfoHttpResponse = userInfoResponse as! HTTPURLResponse
//                                        if userInfoHttpResponse.statusCode != self.sessionExpiryCode {
//                                            failed = true
//                                        }
//                                        requestSemaphore.signal()
//                                    } else {
//                                        failed = true
//                                        requestSemaphore.signal()
//                                    }
//                                })
//
//
//                            } else {
//                                failed = true
//                                requestSemaphore.signal()
//                            }
//                        })
//                    }
//                } else {
//                    failed = true
//                    requestSemaphore.signal()
//                }
//            })
//        } catch {
//            failed = true
//        }
//
//        _ = requestSemaphore.wait(timeout: DispatchTime.distantFuture)
//        XCTAssertTrue(!failed)
//    }
//
//    func testThatCustomHeadersAreSent() {
//        var failed = false
//
//        let resetSemaphore = DispatchSemaphore(value: 0)
//
////        resetAccessTokenValidity(validity: 10, failureCallback: {
////            failed = true
////            resetSemaphore.signal()
////        }, successCallback: {
////            resetSemaphore.signal()
////        })
//
//        _ = resetSemaphore.wait(timeout: DispatchTime.distantFuture)
//
//        let url = URL(string: headerAPIURL)
//        var request = URLRequest(url: url!)
//        request.addValue("st", forHTTPHeaderField: "st-custom-header")
//        let requestSemaphore = DispatchSemaphore(value: 0)
//
//        do {
//            try SuperTokens.`init`(refreshTokenEndpoint: refreshTokenAPIURL, sessionExpiryStatusCode: sessionExpiryCode)
//            SuperTokensURLSession.newTask(request: request, completionHandler: {
//                data, response, error in
//
//                if error != nil {
//                    failed = true
//                    requestSemaphore.signal()
//                    return;
//                }
//
//                if response as? HTTPURLResponse != nil {
//                    let httpResponse = response as! HTTPURLResponse
//
//                    if httpResponse.statusCode != 200 {
//                        failed = true;
//                        requestSemaphore.signal();
//                        return;
//                    }
//
//                    if data == nil {
//                        failed = true;
//                        requestSemaphore.signal();
//                        return;
//                    }
//
//                    do {
//                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
//                        let success = jsonResponse.value(forKey: "success") as? Bool
//                        if success == nil {
//                            failed = true
//                            requestSemaphore.signal()
//                            return
//                        }
//
//                        if !success! {
//                            failed = true
//                        }
//
//                        requestSemaphore.signal()
//                    } catch {
//                        failed = true;
//                        requestSemaphore.signal()
//                    }
//                } else {
//                    failed = true
//                    requestSemaphore.signal()
//                }
//            })
//        } catch {
//            failed = true;
//        }
//
//        _ = requestSemaphore.wait(timeout: .distantFuture)
//        XCTAssertTrue(!failed)
//    }

}