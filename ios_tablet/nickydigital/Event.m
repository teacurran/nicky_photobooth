//
//  Event.m
//  nickydigital
//
//  Created by Terrence Curran on 2/28/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "Event.h"
#import "NDConstants.h"

@implementation Event

int const kAspectPortrait = 1;
const int kAspectLandscape = 2;
const int kAspectSquare = 3;

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
@synthesize facebookLikeText;
@synthesize emailShare;
@synthesize showFacebook;
@synthesize showFacebookLike;
@synthesize showTwitter;
@synthesize showTumblr;
@synthesize showEmail;
@synthesize showWaterfall;

@synthesize tumblrConsumerKey = _tumblrConsumerKey;
@synthesize tumblrConsumerSecret = _tumblrConsumerSecret;

@synthesize twitterConsumerKey = _twitterConsumerKey;
@synthesize twitterConsumerSecret = _twitterConsumerSecret;

@synthesize facebookConsumerKey = _facebookConsumerKey;
@synthesize facebookConsumerSecret = _facebookConsumerSecret;

- (NSString*)tumblrConsumerKey {
	if (_tumblrConsumerKey == nil) {
		return kTumblrConsumerKey;
	}
	return _tumblrConsumerKey;
}
- (NSString*)tumblrConsumerSecret {
	if (_tumblrConsumerSecret == nil) {
		return kTumblrConsumerSecret;
	}
	return _tumblrConsumerSecret;
}

- (NSString*)twitterConsumerKey {
	if (_twitterConsumerKey == nil) {
		return kTwitterConsumerKey;
	}
	return _twitterConsumerKey;
}
- (NSString*)twitterConsumerSecret {
	if (_twitterConsumerSecret == nil) {
		return kTwitterConsumerSecret;
	}
	return _twitterConsumerSecret;
}

- (NSString*)facebookConsumerKey {
	if (_facebookConsumerKey == nil) {
		return kFacebookAppId;
	}
	return _facebookConsumerKey;
}
- (NSString*)facebookConsumerSecret {
	if (_facebookConsumerSecret == nil) {
		return kFacebookSecret;
	}
	return _facebookConsumerSecret;
}



@end
