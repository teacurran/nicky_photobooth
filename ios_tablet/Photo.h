//
//  Photo.h
//  smilebooth
//
//  Created by Terrence Curran on 1/14/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * datecreated;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSNumber * id;

@end
