//
//  NDPhotoGridControllerViewController.h
//  nickydigital
//
//  Created by Terrence Curran on 2/10/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDDynamicGridViewController.h"

@interface NDPhotoGridViewController : BDDynamicGridViewController<BDDynamicGridViewDelegate>{
    NSArray * _items;
}


@end
