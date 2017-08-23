//
//  PhotosViewModel.h
//  MVVM-sample
//
//  Created by Martin Kenarov on 8/8/17.
//  Copyright © 2017 Martin Kenarov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotosViewModel : NSObject

@property (nonatomic, strong) NSMutableArray *photosArray;

- (void)updatePhotos;

@end
