//
//  BUYProductViewHeader.h
//  Mobile Buy SDK
//
//  Created by Rune Madsen on 2015-07-07.
//  Copyright (c) 2015 Shopify Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BUYImageView;

@interface BUYProductViewHeader : UIView

@property (nonatomic, strong) BUYImageView *productImageView;

- (void)setContentOffset:(CGPoint)offset;

@end