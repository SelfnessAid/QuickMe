//
//  RealmUtils.swift
//  Quick Me
//
//  Created by Abdul Wahib on 5/3/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUtils {
    
    class RequestTable {
        
        class func save(request: Request) {
            if isAlreadExists(request.requestId) {
                update(request)
            }
            
            do {
                let realm = try Realm()
                try realm.write({ () -> Void in
                    realm.add(request)
                })
            }catch {
                print("Error in Class:RealmUtils.RequestTable Method: save")
                print(error)
            }
        }
        
        class func isAlreadExists(id: String) -> Bool {
            do {
                let realm = try Realm()
                let requests = realm.objects(Request).filter("requestId = '\(id)'")
                return requests.count > 0
            }catch {
                print("Error in Class:RealmUtils.Request Method: isAlreadExists")
                print(error)
            }
            return false
        }
        
        class func getNewId() -> Int {
            do {
                let realm = try Realm()
                let requests = realm.objects(Request)
                return (requests.count + 1)
            }catch {
                print("Error in Class:RealmUtils.Request Method: getNewId")
                print(error)
            }
            return 0
        }
        
        class func getById(requestId: String) -> Request? {
            do {
                let realm = try Realm()
                let requests = realm.objects(Request).filter("requestId = '\(requestId)'")
                return requests[0]
            }catch {
                print("Error in Class:RealmUtils.RequestTable Method: readAll")
                print(error)
            }
            return nil
        }
        
        class func readAll() -> [Request] {
            var requestsArray = [Request]()
            do {
                let realm = try Realm()
                let requests = realm.objects(Request)
                for request in requests {
                    requestsArray.append(request)
                }
                return requestsArray
            }catch {
                print("Error in Class:RealmUtils.RequestTable Method: readAll")
                print(error)
            }
            return requestsArray
        }
        
        class func readAll(clientId: String) -> [Request]{
            var requestsArray = [Request]()
            do {
                let realm = try Realm()
                let requests = realm.objects(Request).filter("clientId = '\(clientId)'")
                for request in requests {
                    requestsArray.append(request)
                }
                return requestsArray
            }catch {
                print("Error in Class:RealmUtils.RequestTable Method: readAllByClientId")
                print(error)
            }
            return requestsArray
        }
        
        class func readAllOthersRequest(clientId: String) -> [Request] {
            var requestsArray = [Request]()
            do {
                let realm = try Realm()
//                let requests = realm.objects(Request).filter("clientId != '\(clientId)'")
                let requests = realm.objects(Request).filter("isFromPush = true")
                for request in requests {
                    requestsArray.append(request)
                }
                return requestsArray
            }catch {
                print("Error in Class:RealmUtils.RequestTable Method: readAllOthersRequest")
                print(error)
            }
            return requestsArray
        }
        
        class func update(request: Request) {
            do {
                let realm = try Realm()
                try realm.write({ () -> Void in
                    realm.add(request,update: true)
                })
            }catch {
                print("Error in Class:RealmUtils.RequestTable Method: update")
                print(error)
            }
        }
        
        class func getRequest(requestId: String) -> Request? {
            do {
                let realm = try Realm()
                let requests = realm.objects(Request).filter("requestId = '\(requestId)'")
                if requests.count > 0 {
                    return requests[0]
                }
            }catch {
                print("Error in Class:RealmUtils.RequestTable Method: getRequest")
                print(error)
            }
            return nil
        }
        
        class func cancelRequest(requestId: String) {
            if let request = getRequest(requestId) {
                do {
                    let realm = try Realm()
                    try realm.write({ () -> Void in
                        if !request.invalidated {
                            realm.delete(request)
                        }
//                        request.isCancelled = true
                    })
                }catch {
                    print(error)
                }
            }
        }
        
    }
    
    class OfferTable {
        
        class func save(offer: Offer) {
            if isAlreadExists(offer.offerId) {
                update(offer)
            }
            
            do {
                let realm = try Realm()
                try realm.write({ () -> Void in
                    realm.add(offer)
                })
            }catch {
                print("Error in Class:RealmUtils.RequestTable Method: save")
                print(error)
            }
        }
        
        class func isAlreadExists(id: String) -> Bool {
            do {
                let realm = try Realm()
                let offers = realm.objects(Offer).filter("offerId = '\(id)'")
                return offers.count > 0
            }catch {
                print("Error in Class:RealmUtils.OfferTable Method: isAlreadExists")
                print(error)
            }
            return false
        }
        
        class func getNewId() -> Int {
            do {
                let realm = try Realm()
                let offers = realm.objects(Offer)
                return (offers.count + 1)
            }catch {
                print("Error in Class:RealmUtils.OfferTable Method: getNewId")
                print(error)
            }
            return 0
        }
        
        class func readAll() -> [Offer] {
            var offersArray = [Offer]()
            do {
                let realm = try Realm()
                let offers = realm.objects(Offer)
                for offer in offers {
                    offersArray.append(offer)
                }
                return offersArray
            }catch {
                print("Error in Class:RealmUtils.OfferTable Method: readAll")
                print(error)
            }
            return offersArray
        }
        
        class func getAllRequestOffers(requestId: String) -> [Offer] {
            var offersArray = [Offer]()
            do {
                let realm = try Realm()
                let offers = realm.objects(Offer).filter("requestId = '\(requestId)'")
                for offer in offers {
                    offersArray.append(offer)
                }
                return offersArray
            }catch {
                print("Error in Class:RealmUtils.OfferTable Method: readAll")
                print(error)
            }
            return offersArray
        }
        
        class func update(offer: Offer) {
            do {
                let realm = try Realm()
                try realm.write({ () -> Void in
                    realm.add(offer,update: true)
                })
            }catch {
                print("Error in Class:RealmUtils.OfferTable Method: update")
                print(error)
            }
        }
        
        class func updatePrice(offerId: String, price: String) {
            
            if let offer = getOffer(offerId) {
                do {
                    let realm = try Realm()
                    try realm.write({ () -> Void in
                        offer.lastPrice = Double(price)!
                    })
                }catch {
                    print(error)
                }
            }
            
        }
        
        class func updateAccepted(offerId: String) {
            
            if let offer = getOffer(offerId) {
                do {
                    let realm = try Realm()
                    try realm.write({ () -> Void in
                        offer.accepted = true
                    })
                }catch {
                    print(error)
                }
            }
            
        }
        
        class func updateClosed(offerId: String) {
            
            if let offer = getOffer(offerId) {
                do {
                    let realm = try Realm()
                    try realm.write({ () -> Void in
                        offer.closed = true
                    })
                }catch {
                    print(error)
                }
            }
            
        }
        
        class func updateDisputed(offerId: String) {
            
            if let offer = getOffer(offerId) {
                do {
                    let realm = try Realm()
                    try realm.write({ () -> Void in
                        offer.isDisputed = true
                    })
                }catch {
                    print(error)
                }
            }
            
        }
        
        class func getOffer(requestId: String, clientId: String) -> Offer? {
            do {
                let realm = try Realm()
                let offers = realm.objects(Offer).filter("requestId = '\(requestId)' AND serverId = '\(clientId)'")
                if offers.count > 0 {
                    return offers[0]
                }
            }catch {
                print("Error in Class:RealmUtils.OfferTable Method: readAll")
                print(error)
            }
            return nil
        }
        
        class func getOffer(offerId: String) -> Offer? {
            do {
                let realm = try Realm()
                let offers = realm.objects(Offer).filter("offerId = '\(offerId)'")
                if offers.count > 0 {
                    return offers[0]
                }
            }catch {
                print("Error in Class:RealmUtils.OfferTable Method: getOfferById")
                print(error)
            }
            return nil
        }
        
        class func getRefundedOffer() -> [Offer] {
            var offersArray = [Offer]()
            do {
                let realm = try Realm()
                let offers = realm.objects(Offer).filter("isRefunded = true AND closed = false")
                for offer in offers {
                    offersArray.append(offer)
                }
                return offersArray
            }catch {
                print("Error in Class:RealmUtils.OfferTable Method: getRefundedOffer")
                print(error)
            }
            return offersArray
        }
        
        class func getOnlyAcceptedOffers() -> [Offer] {
            var offersArray = [Offer]()
            do {
                let realm = try Realm()
                let offers = realm.objects(Offer).filter("accepted = true AND closed = false")
                for offer in offers {
                    offersArray.append(offer)
                }
                return offersArray
            }catch {
                print("Error in Class:RealmUtils.OfferTable Method: getOnlyAcceptedOffers")
                print(error)
            }
            return offersArray
        }
        
        class func cancelOffer(offerId: String) {
            if let offer = getOffer(offerId) {
                do {
                    let realm = try Realm()
                    
                    try realm.write({ () -> Void in
                        realm.delete(offer)
//                        offer.isCancelled = true
                    })
                }catch {
                    print(error)
                }
            }
        }
        
        class func hasAcceptedOffers(requestId: String) -> Bool {
            var offersArray = [Offer]()
            do {
                let realm = try Realm()
                let offers = realm.objects(Offer).filter("requestId = '\(requestId)' && accepted = true")
                for offer in offers {
                    offersArray.append(offer)
                }
                
            }catch {
                print("Error in Class:RealmUtils.OfferTable Method: hasAcceptedOffers")
                print(error)
            }
            return offersArray.count > 0
        }
        
    }
    
    class BalanceHistoryTable {
        
        class func save(item: BalanceHistory) {
            
            do {
                let realm = try Realm()
                try realm.write({ () -> Void in
                    realm.add(item)
                })
            }catch {
                print("Error in Class:RealmUtils.BalanceHistoryTable Method: save")
                print(error)
            }
        }
        
        class func readAll() -> [BalanceHistory] {
            var balanceItems = [BalanceHistory]()
            do {
                let realm = try Realm()
                let items = realm.objects(BalanceHistory)
                for item in items {
                    balanceItems.append(item)
                }
                return balanceItems
            }catch {
                print("Error in Class:RealmUtils.BalanceHistoryTable Method: readAll")
                print(error)
            }
            return balanceItems
        }
        
    }
    
    
}