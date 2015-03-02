//
//  ViewController.m
//  HCSParallaxCarousel
//
//  Created by Sahil Kapoor on 02/03/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import "ViewController.h"
#import "HCSParallaxCarousel.h"
#import "IDMPhotoBrowser.h"

static CGFloat const kCarouselHeight = 200;

@interface ViewController () <HCSParallaxCarouselDelegate, IDMPhotoBrowserDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, strong) HCSParallaxCarousel *tableView;
@property (nonatomic) CGFloat scrollViewTouchLocation;
@property (nonatomic) NSInteger scrollerImageIndex;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self configureTableView];
}

- (void)configureTableView {
    _tableView = [[HCSParallaxCarousel alloc] initWithFrame:self.view.bounds
                                                      style:UITableViewStylePlain
                                             carouselHeight:kCarouselHeight];
    [self.view addSubview:_tableView];
    self.tableView.carouselDelegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    _scrollerImageIndex = 0;
    [self.tableView reloadCarouselData];
}

#pragma mark - HCSCarouselDelegate

- (NSUInteger)numberOfImagesAvailableForImageScroller:(UIView *)scroller {
    return 5;
}

- (id)imageScroller:(UIView *)scroller infoForItemAtIndex:(NSUInteger)index {
    switch (index) {
        case 0:return self.urls[0];
        case 1:return self.urls[1];
        case 2:return self.urls[2];
        default:return self.urls[3];
    }
}

- (void)imageScroller:(UIView *)scroller didSelectImageAtIndex:(NSUInteger)index {
    [self openIdmBroswerWithView:scroller];
}

- (void)imageScroller:(UIView *)scroller didScrollToHeight:(CGFloat)height {
    if (height > (kCarouselHeight + 100) && self.scrollViewTouchLocation < 150) {
        [self openIdmBroswerWithView:scroller];
    }
}

- (void)didChangeToPageAtIndex:(NSInteger)page {
    self.scrollerImageIndex = page;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Row: %li", indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGPoint location = [scrollView.panGestureRecognizer locationInView:scrollView];
    self.scrollViewTouchLocation = location.y;
}

#pragma mark - IDMPhotoBrowserDelegate

- (void)photoBrowser:(IDMPhotoBrowser *)photoBrowser didShowPhotoAtIndex:(NSUInteger)index {
    [self.tableView scrollToImageAtIndex:index animated:YES];
}

#pragma mark - Helper Methods

- (void)openIdmBroswerWithView:(UIView *)view {
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotoURLs:self.urls animatedFromView:view];
    [browser setInitialPageIndex:self.scrollerImageIndex];
    browser.displayActionButton = NO;
    browser.displayArrowButton = YES;
    browser.displayCounterLabel = YES;
    browser.delegate = self;
    [self presentViewController:browser animated:YES completion:nil];
}

- (NSArray *)urls {
    return @[[NSURL URLWithString:@"http://cdn.filmschoolrejects.com/images/mondo-heavy-metal-670x380.jpg"],
             [NSURL URLWithString:@"http://www.fun2smiles.com/wp-content/uploads/2014/10/hoods_are_cool____by_moni158-d6dam6q-36.jpg"],
             [NSURL URLWithString:@"http://masspictures.net/wp-content/uploads/2014/04/young-and-stupid-cool-quotes.jpg"],
             [NSURL URLWithString:@"http://www.graphics99.com/wp-content/uploads/2012/06/cool.jpg"]];
}

@end
