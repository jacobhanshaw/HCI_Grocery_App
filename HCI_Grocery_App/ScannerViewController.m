//
//  ViewController.m
//  iOS7_BarcodeScanner
//
//  Created by Jake Widmer on 11/16/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//


#import "ScannerViewController.h"

#import "Barcode.h"

@interface ScannerViewController ()<UIAlertViewDelegate, AVCaptureMetadataOutputObjectsDelegate>
@end

@implementation ScannerViewController{
    
    id<ScannerViewControllerDelegate> _delegate;
    NSMutableArray *_allowedBarcodeTypes;

    UIView *_previewView;
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_videoDevice;
    AVCaptureDeviceInput *_videoInput;
    AVCaptureVideoPreviewLayer *_previewLayer;
    BOOL _running;
    AVCaptureMetadataOutput *_metadataOutput;
}

- (ScannerViewController *) initWithDelegate:(id<ScannerViewControllerDelegate>) delegate
{
    if((self = [super init]))
        _delegate = delegate;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCaptureSession];
    _previewLayer.frame = _previewView.bounds;
    [_previewView.layer addSublayer:_previewLayer];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillEnterForeground:)
     name:UIApplicationWillEnterForegroundNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidEnterBackground:)
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
    
    _allowedBarcodeTypes = [NSMutableArray new];
    [_allowedBarcodeTypes addObject:@"org.iso.QRCode"];
    [_allowedBarcodeTypes addObject:@"org.iso.PDF417"];
    [_allowedBarcodeTypes addObject:@"org.gs1.UPC-E"];
    [_allowedBarcodeTypes addObject:@"org.iso.Aztec"];
    [_allowedBarcodeTypes addObject:@"org.iso.Code39"];
    [_allowedBarcodeTypes addObject:@"org.iso.Code39Mod43"];
    [_allowedBarcodeTypes addObject:@"org.gs1.EAN-13"];
    [_allowedBarcodeTypes addObject:@"org.gs1.EAN-8"];
    [_allowedBarcodeTypes addObject:@"com.intermec.Code93"];
    [_allowedBarcodeTypes addObject:@"org.iso.Code128"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startRunning];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - AV capture methods

- (void)setupCaptureSession {
    if (_captureSession)
        return;

    _videoDevice = [AVCaptureDevice
                    defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (!_videoDevice) {
        NSLog(@"No video camera on this device!");
        return;
    }

    _captureSession = [[AVCaptureSession alloc] init];

    _videoInput = [[AVCaptureDeviceInput alloc]
                   initWithDevice:_videoDevice error:nil];

    if ([_captureSession canAddInput:_videoInput])
        [_captureSession addInput:_videoInput];

    _previewLayer = [[AVCaptureVideoPreviewLayer alloc]
                     initWithSession:_captureSession];
    _previewLayer.videoGravity =
    AVLayerVideoGravityResizeAspectFill;
    
    
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metadataQueue =
    dispatch_queue_create("com.1337labz.featurebuild.metadata", 0);
    [_metadataOutput setMetadataObjectsDelegate:self
                                          queue:metadataQueue];
    if ([_captureSession canAddOutput:_metadataOutput]) {
        [_captureSession addOutput:_metadataOutput];
    }
}

- (void)startRunning {
    if (_running) return;
    [_captureSession startRunning];
    _metadataOutput.metadataObjectTypes =
    _metadataOutput.availableMetadataObjectTypes;
    _running = YES;
}
- (void)stopRunning {
    if (!_running) return;
    [_captureSession stopRunning];
    _running = NO;
}

//  handle going foreground/background
- (void)applicationWillEnterForeground:(NSNotification*)note {
    [self startRunning];
}
- (void)applicationDidEnterBackground:(NSNotification*)note {
    [self stopRunning];
}

#pragma mark - Delegate functions

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    [metadataObjects
     enumerateObjectsUsingBlock:^(AVMetadataObject *obj,
                                  NSUInteger idx,
                                  BOOL *stop)
     {
         if ([obj isKindOfClass:
              [AVMetadataMachineReadableCodeObject class]])
         {
             AVMetadataMachineReadableCodeObject *code =
             (AVMetadataMachineReadableCodeObject*)
             [_previewLayer transformedMetadataObjectForMetadataObject:obj];
             
             Barcode * barcode = [Barcode processMetadataObject:code];
             
             for(NSString * str in _allowedBarcodeTypes){
                if([barcode.getBarcodeType isEqualToString:str]){
                    [self validBarcodeFound:barcode];
                    return;
                }
            }
         }
     }];
}

- (void) validBarcodeFound:(Barcode *)barcode
{
    [self stopRunning];
    
    if(_delegate)
    {
        BOOL continueRunning = [_delegate scannedItem:[barcode getBarcodeData]];
        if(continueRunning)
            [self startRunning];
    }
    else
        [self showBarcodeAlert:barcode];
}
- (void) showBarcodeAlert:(Barcode *)barcode
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * alertMessage = @"%@ You found a barcode with data ";
        alertMessage = [alertMessage stringByAppendingString:[barcode getBarcodeData]];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Barcode Found!"
                                                          message:alertMessage
                                                         delegate:self
                                                cancelButtonTitle:@"Done"
                                                otherButtonTitles:@"Scan again",nil];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [message show];
        });
    });
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        //Code for Done button
        // TODO: Create a finished view
    }
    if(buttonIndex == 1){
        //Code for Scan more button
        [self startRunning];
    }
}

@end


