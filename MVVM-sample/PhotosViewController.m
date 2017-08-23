//
//  PhotosViewController.m
//  MVVM-sample
//
//  Created by Martin Kenarov on 8/8/17.
//  Copyright © 2017 Martin Kenarov. All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotosViewModel.h"
#import "PhotoCollectionViewCell.h"
#import <KVOController/KVOController.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <HTProgressHUD/HTProgressHUD.h>

static NSString * const PhotoCellIdentifier = @"PhotoCellIdentifier";
static NSString * const PhotoCollectionViewCellIdentifier = @"PhotoCollectionViewCell";

@interface PhotosViewController () <UICollectionViewDataSource>

@property (nonatomic, strong) PhotosViewModel *viewModel;
@property (nonatomic, strong) FBKVOController *kvoController;
@property (nonatomic, strong) HTProgressHUD *spinner;

@property (nonatomic, weak) IBOutlet UICollectionView *photosCollectionView;

@end

@implementation PhotosViewController

#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.kvoController = [FBKVOController controllerWithObserver:self];
    // initialize view model
    self.viewModel = [PhotosViewModel new];
    self.spinner = [HTProgressHUD new];
    
    [self.photosCollectionView setDataSource:self];
    
     [self.photosCollectionView registerNib:[UINib nibWithNibName:PhotoCollectionViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:PhotoCellIdentifier];
    
    [self setupObservers];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView datasource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel.photosArray count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *photoInfo = [self.viewModel.photosArray objectAtIndex:indexPath.row];
    NSString *urlString = photoInfo[@"url_q"];
    
    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:urlString]];
    
    return cell;
}

#pragma mark - IBActions 

- (IBAction)reladImageAction:(id)sender
{
    [self reloadData];
}

#pragma mark - Helpers

- (void)setupObservers
{
    [self.kvoController observe:self.viewModel keyPath:@"photosArray" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        [self.spinner hideWithAnimation:YES];
        [self.photosCollectionView reloadData];
    }];
}

- (void)reloadData {
    self.spinner.text = @"Loading..";
    [self.spinner showInView:self.view];
    
    [self.viewModel updatePhotos];
}

@end
