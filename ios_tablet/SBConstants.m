//
//  SBConstants.m
//  smilebooth
//
//  Created by Terrence Curran on 1/14/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "SBConstants.h"

@implementation SBConstants

NSString* const kSmileBoothUploaderUrl = @"http://0xffffff.local";
NSString* const kSMileBoothAuthUrl = @"http://smilebooth.dev-server-host.com";

NSString* const kFacebookAppId = @"596065173744275";
NSString* const kFacebookSecret = @"272dec3fa799dc5751205642ad90318a";
NSString* const kFacebookRedirect = @"http://www.nickydigital.com/facebook/auth";
NSString* const kFacebookScope = @"publish_actions";

NSString* const kFacebookOauth = @"https://www.facebook.com/dialog/oauth/?display=touch&response_type=token&client_id=%@&redirect_uri=%@&state=%@&scope=%@";

@end
