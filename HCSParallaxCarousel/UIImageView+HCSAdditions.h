//
//  UIImageView+HCSAdditions.h
//  HCSParallaxCarousel
//
//  Created by Sahil Kapoor on 02/03/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+XLNetworking.h"

@interface UIImageView (HCSAdditions)

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest // new url
            fallbackURLRequest:(NSURLRequest *)fallbackURLRequest // old url
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, UIImage *))success
                       failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure
         downloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgressBlock;

@end
