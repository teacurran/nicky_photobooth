//
//  Photo.h
//  smilebooth
//
//  Created by Terrence Curran on 1/14/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSObject


@property NSString * filename;
@property NSNumber * fileId;
@property UIImageView * thumbView;

@end
