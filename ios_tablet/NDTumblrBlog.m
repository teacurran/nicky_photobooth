//
//  NDTumblrBlog.m
//  nickydigital
//
//  Created by Terrence Curran on 3/12/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "NDTumblrBlog.h"

@implementation NDTumblrBlog

@synthesize name;
@synthesize title;
@synthesize url;
@synthesize hostname = _hostname;

- (NSString*)hostname {
	if (url == nil) {
		return nil;
	}
	NSRange hostRange;
	hostRange.location = [url rangeOfString:@"//"].location + 2;
	hostRange.length = [url length] - hostRange.location - 1;
	_hostname = [url substringWithRange:hostRange];
	return _hostname;
}

@end
