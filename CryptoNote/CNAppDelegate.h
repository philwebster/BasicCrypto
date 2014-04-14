//
//  CNAppDelegate.h
//  CryptoNote
//
//  Created by Phil Webster on 3/31/14.
//  Copyright (c) 2014 philwebster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
