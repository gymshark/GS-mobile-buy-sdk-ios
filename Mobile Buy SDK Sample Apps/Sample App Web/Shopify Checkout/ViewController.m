//
//  ViewController.m
//  Checkout
//
//  Created by Shopify.
//  Copyright (c) 2015 Shopify. All rights reserved.
//

#import "ViewController.h"
#import "CheckoutSelectionController.h"

@interface ViewController () <BUYStoreViewControllerDelegate, CheckoutSelectionControllerDelegate>
@property (nonatomic, copy) BUYCheckoutTypeBlock callback;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.delegate = self;
    
    // Add a home button to the navigation bar
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    button.tintColor = [UIColor whiteColor];
    UIImage *buttonImage = [UIImage imageNamed:@"shop"];
    [button setImage:[buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 53, 31)];
    [button addTarget:self action:@selector(goHome)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // Get shop details
    [self.client getShop:^(BUYShop *shop, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error == nil && shop) {
                self.title = shop.name;
            }
            else {
                NSLog(@"Error fetching shop: %@", error.localizedDescription);
            }
        });
    }];
}

#pragma mark - BUYStoreViewController delegate methods

- (void)controller:(BUYStoreViewController *)controller shouldProceedWithCheckoutType:(BUYCheckoutTypeBlock)completionHandler
{
    // If ApplePay is not setup, proceed to normal checkout
    if (self.isApplePayAvailable)
    {
        CheckoutSelectionController *selectionController = [[CheckoutSelectionController alloc] init];
        selectionController.delegate = self;
        self.callback = completionHandler;
        
        [self presentViewController:selectionController animated:YES completion:nil];
    }
    else {
        completionHandler(BUYCheckoutTypeNormal);
    }
}

- (void)controller:(BUYViewController *)controller failedToCreateCheckout:(NSError *)error
{
    NSLog(@"Failed to create checkout: %@", error);
}

- (void)controllerFailedToStartApplePayProcess:(BUYViewController *)controller
{
    NSLog(@"Failed to start the Apple Pay process. We weren't given an error :(");
}

- (void)controller:(BUYViewController *)controller failedToUpdateCheckout:(BUYCheckout *)checkout withError:(NSError *)error
{
    NSLog(@"Failed to update checkout: %@, error: %@", checkout.token, error);
}

- (void)controller:(BUYViewController *)controller failedToGetShippingRates:(BUYCheckout *)checkout withError:(NSError *)error
{
    NSLog(@"Failed to get shipping rates: %@, error: %@", checkout.token, error);
}

- (void)controller:(BUYViewController *)controller failedToCompleteCheckout:(BUYCheckout *)checkout withError:(NSError *)error
{
    NSLog(@"Failed to complete checkout: %@, error: %@", checkout.token, error);
}

- (void)controller:(BUYViewController *)controller didCompleteCheckout:(BUYCheckout *)checkout status:(BUYStatus)status
{
    NSLog(@"Did complete checkout: %@, status: %ld", checkout.token, (unsigned long)status);
}

#pragma mark - PAYSelectionController delegate

- (void)checkoutSelectionControllerCancelled:(CheckoutSelectionController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)checkoutSelectionController:(CheckoutSelectionController *)controller selectedCheckoutType:(CheckoutType)checkoutType
{
    self.callback(checkoutType == CheckoutTypeApplePay ? BUYCheckoutTypeApplePay : BUYCheckoutTypeNormal);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
