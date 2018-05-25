//
//  IAPProviderDelegate.swift
//  F.I.T.
//
//  Created by Felix Belau on 18.04.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation

@objc protocol IAPProviderDelegate
{
    func transactionSuccessful();
    func transactionFailed();
    func fetchingFinished();
    func restoreTransactionsFinished();
    func restoreTransactionsFailed();
    
}