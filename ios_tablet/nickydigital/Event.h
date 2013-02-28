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
@property int eventId;
@property NSString * code;
@property NSString * banner;
@property NSString * name;
@property NSString * album;
@property NSString * shortShare;
@property NSString * longShare;

@end
