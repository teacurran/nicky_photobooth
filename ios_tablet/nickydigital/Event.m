//
//  Event.m
//  nickydigital
//
//  Created by Terrence Curran on 2/28/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "Event.h"

@implementation Event

+ (void)initialize {
	[super initialize];
}

@synthesize eventId;
@synthesize code;
@synthesize banner;
@synthesize name;
@synthesize album;
@synthesize shortShare;
@synthesize longShare;
@synthesize tumblrShare;
@synthesize emailShare;
@synthesize showFacebook;
@synthesize showTwitter;
@synthesize showTumblr;
@synthesize showEmail;

@end
