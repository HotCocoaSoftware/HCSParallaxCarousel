//
//  UIImageView+HCSAdditions.m
//  HCSParallaxCarousel
//
//  Created by Sahil Kapoor on 02/03/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import "UIImageView+HCSAdditions.h"

@implementation UIImageView (HCSAdditions)

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest // new url
            fallbackURLRequest:(NSURLRequest *)fallbackURLRequest // old url
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, UIImage *))success
                       failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure
         downloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgressBlock {
    UIImageView * __weak weakSelf = self;
    
    [self setImageWithURLRequest:urlRequest
                placeholderImage:placeholderImage
                         success:success
                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                             if (failure) {
                                 UIImageView *strongSelf = weakSelf;
                                 if (!strongSelf) {
                                     return ;
                                 }
                                 [strongSelf setImageWithURLRequest:fallbackURLRequest
                                                   placeholderImage:placeholderImage
                                                            success:success
                                                            failure:failure
                                              downloadProgressBlock:downloadProgressBlock];
                             }
                         }
           downloadProgressBlock:downloadProgressBlock];
}


@end
