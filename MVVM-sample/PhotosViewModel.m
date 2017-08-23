//
//  PhotosViewModel.m
//  MVVM-sample
//
//  Created by Martin Kenarov on 8/8/17.
//  Copyright © 2017 Martin Kenarov. All rights reserved.
//

#import "PhotosViewModel.h"
#import <UIKit/UIKit.h>

@interface PhotosViewModel()

@end

@implementation PhotosViewModel

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    
    if (self) {
        _photosArray = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - Public methods

- (void)updatePhotos
{
    [self downloadImagesFromFlickrWithCompletionBlock:^(NSArray *photos) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photosArray removeAllObjects];
            [[self mutableArrayValueForKeyPath:@"photosArray"] addObjectsFromArray:photos];
        });
    } failureBlock:^(NSError *error) {
        NSLog(@"ERROR : %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"FlickrApp", nil) message:NSLocalizedString(@"Error fetching feed.", nil) preferredStyle:UIAlertControllerStyleAlert];
            [alert presentViewController:alert animated:YES completion:nil];
        });
    }];
}

#pragma mark - Helpers

- (void)downloadImagesFromFlickrWithCompletionBlock:(void (^)(NSArray *photos))success failureBlock:(void (^)(NSError *error))failure
{
    NSString *urlString = @"https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=80bfbd87ab15ec86dca6854950d6d1db&per_page=99&format=json&nojsoncallback=1&extras=url_q,url_z";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionConfiguration *urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:urlSessionConfiguration];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (!error && httpResponse.statusCode == 200) {
            NSError *parseError;
            
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            
            if (parseError) {
                failure(parseError);
            } else {
                
                if (json) {
                    if ([json isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *resultDictionary = (NSDictionary *) json;
                        NSDictionary *dict = [resultDictionary objectForKey:@"photos"];
                        NSArray *results = [dict objectForKey:@"photo"];
                        success(results);
                    } else {
                        NSDictionary *userInfo = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to fetch photos", nil),
                                                   };
                        error = [NSError errorWithDomain:@"" code:-100 userInfo:userInfo];
                        failure(error);
                    }
                }
            }
        } else {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to fetch photos", nil),
                                       };
            error = [NSError errorWithDomain:@"" code:-100 userInfo:userInfo];
            failure(error);
        }
    }];
    
    [dataTask resume];
}
@end
