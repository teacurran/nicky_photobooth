//
//  NDApiClient.m
//  nickydigital
//
//  Created by Terrence Curran on 3/2/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "NDApiClient.h"
#import "NDConstants.h"
#import "AFJSONRequestOperation.h"

@implementation NDApiClient

+(NDApiClient *)sharedClient {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	static NDApiClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:[defaults stringForKey:kPrefServerUrlKey]]];
    });
    return _sharedClient;
}

-(id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    self.parameterEncoding = AFJSONParameterEncoding;
	
    return self;
	
}

@end
