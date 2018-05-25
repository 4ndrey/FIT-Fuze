//
//  IAPProvider.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 11.04.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import StoreKit
import SystemConfiguration
import MagicalRecord

class IAPProvider: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    static let sharedInstance = IAPProvider()

    var programId : String?
    
    var trainingPrograms = Dictionary<String, SKProduct>()
    var availablePrograms = Array<String>()
    var programsFetched = false
    var fetchingInProgress = false
    var inAppPurchasesAllowed = true
    let reachability = Reachability()!

    var delegate : IAPProviderDelegate?
    var viewController : UIViewController?
    
    override init()
    {
        super.init()
        self.availablePrograms.append("paid001")
        self.availablePrograms.append("paid002")
        self.availablePrograms.append("paid003")
        self.availablePrograms.append("paid004")
        self.availablePrograms.append("paid005")
        self.availablePrograms.append("paid010")
        self.availablePrograms.append("paid011")
        self.availablePrograms.append("paid012")
        self.availablePrograms.append("paid013")
        SKPaymentQueue.default().add(self)
    }
    
    deinit
    {
      SKPaymentQueue.default().remove(self)
    }
    
    
    func fetchTrainingPrograms()
    {
        if isConnectedToNetwork()
        {
            self.inAppPurchasesAllowed = SKPaymentQueue.canMakePayments()
            if (SKPaymentQueue.canMakePayments() && !fetchingInProgress)
            {
                let programsSet = Set(availablePrograms);
                let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: programsSet);
                productsRequest.delegate = self;
                fetchingInProgress = true
                productsRequest.start();
            }else{
            }
        }    
    }
    
    func buyTrainingProgram(_ programId : String){

        if !isConnectedToNetwork()
        {
            if viewController != nil
            {
                let button2Alert = UIAlertController(title: NSLocalizedString("IAP_no_internet_title", comment:"No internet connection"), message: NSLocalizedString("IAP_no_internet_text", comment:"Ask to re-connect or try later"), preferredStyle: UIAlertControllerStyle.alert)
                button2Alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                viewController!.present(button2Alert, animated: true, completion: nil)
            }
            return
        }
        
        // We check that we are allow to make the purchase.
        if (SKPaymentQueue.canMakePayments())
        {
            if programsFetched
            {
                let product = trainingPrograms[programId]
                if product == nil
                {
                    if viewController != nil
                    {
                        let button2Alert = UIAlertController(title: NSLocalizedString("IAP_error_title", comment:"Error message title"), message: NSLocalizedString("IAP_error_no_training_plan_text", comment:"Error message - no training plan - text"), preferredStyle: UIAlertControllerStyle.alert)
                        button2Alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        viewController!.present(button2Alert, animated: true, completion: nil)
                    }
                }
                else
                {
                    buyProduct(product!);
                }
            }
            else
            {
                if !fetchingInProgress
                {
                    fetchTrainingPrograms()
                }
                
                if viewController != nil
                {
                    let button2Alert = UIAlertController(title: NSLocalizedString("IAP_info_title", comment:"Info message title"), message: NSLocalizedString("IAP_loading_training_plans_text", comment:"Info about loading tr.plans"), preferredStyle: UIAlertControllerStyle.alert)
                    button2Alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    viewController!.present(button2Alert, animated: true, completion: nil)
                }
            }
            
            
            
        }else{
            
            if viewController != nil
            {
                let button2Alert = UIAlertController(title: NSLocalizedString("IAP_error_title", comment:"Error message title"), message: NSLocalizedString("IAP_purchase_not_possible_text", comment:"Purchase not possible message text"), preferredStyle: UIAlertControllerStyle.alert)
                button2Alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                viewController!.present(button2Alert, animated: true, completion: nil)
            }
        }
    }
    
    func restorePurchasedTrainingPrograms()
    {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
 
    fileprivate func buyProduct(_ product: SKProduct){
        print("Sending the Payment Request to Apple");
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment);
        
    }
    
    // Delegate Methods for IAP
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("got the request from Apple")
        let count : Int = response.products.count
        if (count>0) {
            let validProducts = response.products
            for validProduct in validProducts
            {
                let product: SKProduct = validProduct 
                self.trainingPrograms[validProduct.productIdentifier] = product
            }
            programsFetched = true
            if delegate != nil
            {
                self.delegate!.fetchingFinished()
            }
            
        } else {
            print("nothing")
        }
        fetchingInProgress = false
    }
    
    
    func request(_ request: SKRequest, didFailWithError error: Error)
    {
        fetchingInProgress = false;
        self.delegate?.transactionFailed();
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        print("Received Payment Transaction Response from Apple");
        
        for trans:SKPaymentTransaction in transactions {
                switch trans.transactionState {
                case .purchased, .restored:
                    print("Product Purchased");
                    SKPaymentQueue.default().finishTransaction(trans)
                    let programId = trans.payment.productIdentifier
                    setTrainingProgramPurchased(programId)
                    break;
                case .failed:
                    print("Purchased Failed");
                    SKPaymentQueue.default().finishTransaction(trans)
                    if delegate != nil
                    {
                        self.delegate!.transactionFailed();
                    }
                    let button2Alert: UIAlertView = UIAlertView(title: NSLocalizedString("IAP_error_title", comment:"Error message title"), message: NSLocalizedString("IAP_servers_down_message", comment:"No answer from Apple"),
                        delegate: nil, cancelButtonTitle: "OK")
                    button2Alert.show()
                    break;
                default:
                    break;
                }
            }
        
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue:SKPaymentQueue)
    {
        for transaction:AnyObject in queue.transactions
        {
            let trans : SKPaymentTransaction = transaction as! SKPaymentTransaction
            let identifier : NSString = trans.payment.productIdentifier as NSString //originalTransaction
            setTrainingProgramPurchased(identifier as String)
        }
        if delegate != nil
        {
            self.delegate!.restoreTransactionsFinished();
        }
    }
    
    func  paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error)
    {
        if delegate != nil
        {
            self.delegate!.restoreTransactionsFailed();
        }
    }
    
    fileprivate func setTrainingProgramPurchased(_ programId : String)
    {
        let contentProvider = ContentProvider()
        let program = contentProvider.getTrainingProgramWithId(programId)
        
        if program != nil
        {
            let trainingProgram = program!
            trainingProgram.isPurchased = true
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
            
            self.delegate?.transactionSuccessful();
            
        }
        
        
    }
    
    fileprivate func isConnectedToNetwork() -> Bool {
        return reachability.currentReachabilityStatus != .notReachable
    }
    
    func areProgramsFetched() -> Bool
    {
        if programsFetched
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func getPrice(_ programId : String) -> String?
    {
        let product = trainingPrograms[programId]
// WARNING - this should never happen!
        if(product == nil) {
            return " "
        }
        let price = product!.price
        let formatter = NumberFormatter()
        formatter.formatterBehavior = NumberFormatter.Behavior.behavior10_4
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = product?.priceLocale
        return formatter.string(from: price)
    }

}
