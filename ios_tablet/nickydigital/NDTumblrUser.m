//
//  NDTumblrUser.m
//  nickydigital
//
//  Created by Terrence Curran on 3/12/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "NDTumblrUser.h"

@implementation NDTumblrUser

@synthesize name;
@synthesize blogs = _blogs;

- (NSMutableArray*)blogs {
	if (_blogs == nil) {
		_blogs = [[NSMutableArray alloc] init];
	}
	return _blogs;
}


@end
