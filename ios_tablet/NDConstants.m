//
//  NDConstants.m
//  Nicky Digital
//
//  Created by Terrence Curran on 1/14/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "NDConstants.h"

@implementation NDConstants

int const kGridBorderWidth = 2;

NSString *const kFacebookAppId = @"596065173744275";
NSString *const kFacebookSecret = @"272dec3fa799dc5751205642ad90318a";
NSString *const kFacebookRedirect = @"http://www.nickydigital.com/facebook/auth";
NSString *const kFacebookScope = @"publish_actions,user_photos,photo_upload,user_photo_video_tags"; //  read_stream, publish_stream, photo_upload";
NSString *const kFacebookOauth = @"https://www.facebook.com/dialog/oauth/?display=touch&response_type=token&client_id=%@&redirect_uri=%@&state=%@&scope=%@";

NSString *const kTwitterConsumerKey = @"MsXMqyi2TzVipDTA6vpvw";
NSString *const kTwitterConsumerSecret = @"P9quxz9SXZY3wtr3f258zQPl7XDmhh4zsh4DlKpc";

NSString *const kPrefServerUrlKey = @"server_preference";
NSString *const kPrefServerUrlDefault = @"http://0xffffff.local";

NSString *const kEmailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

NSString *const kTumblrConsumerKey = @"tSISWrYGOOcg0L9HlAJuHxnqxIRmSZjD66mGUvqiyP47UT60cQ";
NSString *const kTumblrConsumerSecret = @"87ALrtQs5HqMGvxKRLIMQYcRbIoFWSGJHAnDJX7yPqKhJtHP9I";
NSString *const kTumblrRequestTokenUrl = @"https://www.tumblr.com/oauth/request_token";
NSString *const kTumblrAuthorizeUrl = @"https://www.tumblr.com/oauth/authorize";
NSString *const kTumblrAccessTokenUrl = @"https://www.tumblr.com/oauth/access_token";
NSString *const kTumblrCallBackUrl = @"http://www.nickydigital.com";
NSString *const kTumblrUserInfo = @"https://api.tumblr.com/v2/user/info";
@end
