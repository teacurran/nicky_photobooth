//
//  NDApiClient.h
//  nickydigital
//
//  Created by Terrence Curran on 3/2/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface NDApiClient : AFHTTPClient

+(NDApiClient *)sharedClient;

@end

