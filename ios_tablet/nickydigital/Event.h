//
//  Event.h
//  nickydigital
//
//  Created by Terrence Curran on 2/28/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

// {
// id: 1,
// code: "citi",
// banner: "/event/citi.jpg",
// name: "NickyDigital Citi",
// album_name: "NickyDigital Citi Album",
// short_share: "Short Share #text",
// long_share: "This is long share text."
// }
extern int const kAspectPortrait;
extern int const kAspectLandscape;
extern int const kAspectSquare;

@property int eventId;
@property NSString *code;
@property NSString *banner;
@property NSString *name;
@property NSString *album;
@property NSString *shortShare;
@property NSString *emailShare;
@property NSString *longShare;
@property NSString *tumblrShare;
@property NSString *facebookLikeText;
@property bool showFacebook;
@property bool showFacebookLike;
@property bool showTwitter;
@property bool showTumblr;
@property bool showEmail;
@property bool showWaterfall;
@property int thumbAspect;

@property (nonatomic) NSString *tumblrConsumerKey;
@property (nonatomic) NSString *tumblrConsumerSecret;

@property (nonatomic) NSString *twitterConsumerKey;
@property (nonatomic) NSString *twitterConsumerSecret;

@property (nonatomic) NSString *facebookConsumerKey;
@property (nonatomic) NSString *facebookConsumerSecret;

@end
