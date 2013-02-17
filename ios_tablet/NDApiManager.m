//
//  NDApiManager.m
//  smilebooth
//
//  Created by Terrence Curran on 1/14/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "NDApiManager.h"
#import "NDConstants.h"
#import "Photo.h"

@implementation NDApiManager

+ (void)initialize {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
    // make sure that RestKit is ready to go
    [self managerWithBaseURL:[NSURL URLWithString:[defaults stringForKey:kPrefServerUrlKey]]];
    
    // show the network activity spinner during requests
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // if you want RK to log out request/response
    // flip this to 1
#if 0
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
#endif

    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"smilebooth" ofType:@"momd"]];
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];

    [[self sharedManager] setManagedObjectStore: managedObjectStore];
    
//    NSError *error;
//
//    [[self sharedManager] addSQLitePersistentStoreAtPath:[RKApplicationDataDirectory() stringByAppendingPathComponent:@"MyApp.sqlite"] fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
//    objectManager.managedObjectStore = objectStore;
    
    
    [self setupAllRKObjectMappings];
    //[self setupAllRKRouting];
}

+ (void)setupAllRKObjectMappings {
    RKObjectManager *sharedManager = [self sharedManager];
    
    
    RKResponseDescriptor *photoDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self photoObjectMapping]
                                                                                   pathPattern:nil keyPath:@"photos"
                                                                                   statusCodes:[self serverSuccessCodes]];
    
    [sharedManager addResponseDescriptorsFromArray:@[
     photoDescriptor
     ]];
}

+ (NSIndexSet *)serverSuccessCodes {
    static NSIndexSet *_serverSuccessCodes;
    if (!_serverSuccessCodes) {
        _serverSuccessCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    }
    
    return _serverSuccessCodes;
}

+ (NSIndexSet *)serverErrorCodes {
    static NSIndexSet *_serverErrorCodes;
    if (!_serverErrorCodes) {
        _serverErrorCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassServerError);
    }
    return _serverErrorCodes;
}

+ (RKObjectMapping *)photoObjectMapping {
    static RKEntityMapping *_photoMapping;
    
    if (!_photoMapping) {
        _photoMapping = [RKEntityMapping mappingForClass:[Photo class]];
        
        [_photoMapping addAttributeMappingsFromDictionary:@{
         @"id" : @"id",
         @"filename" : @"filename"
         }];
        
        _photoMapping.identificationAttributes = @[ @"id" ];
        
    }
    
    return _photoMapping;
}


@end
