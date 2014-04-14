//
//  CNDetailViewController.m
//  CryptoNote
//
//  Created by Phil Webster on 3/31/14.
//  Copyright (c) 2014 philwebster. All rights reserved.
//

#import "CNDetailViewController.h"

@interface CNDetailViewController ()
- (void)configureView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *encryptButton;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property NSManagedObjectContext *mContext;
@end

@implementation CNDetailViewController

static const UInt8 publicKeyIdentifier[] = "com.cs312.publickey\0";
static const UInt8 privateKeyIdentifier[] = "com.cs312.privatekey\0";

//- (void)save
//{
//    [self.detailItem setValue:_detailText.text forKey:@"noteString"];
//    NSError *error = nil;
//    if (![_mContext save:&error]) {
//        // Replace this implementation with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)setContext:(NSManagedObjectContext *)context
{
    _mContext = context;
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
        self.detailText.text = [self.detailItem valueForKey:@"noteString"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    [self.detailText becomeFirstResponder];
    [self generateKeyPairPlease];
    if ([[_detailItem valueForKey:@"noteString"] isEqualToString:@"Note has been encrypted"]) {
        _encryptButton.title = @"Decrypt";
    } else {
        _encryptButton.title = @"Encrypt";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Text View
//- (void)textViewDidChange:(UITextView *)textView
//{
//    [self save];
//}

# pragma mark - Encryption
- (IBAction)encryptPressed:(id)sender {
    UIBarButtonItem *b = sender;
    if ([b.title isEqualToString:@"Encrypt"]) {
        [_detailItem setValue:[self encryptWithPublicKey:[_detailText.text dataUsingEncoding:NSUTF8StringEncoding]] forKey:@"cipherText"];
        [_detailItem setValue:@"Note has been encrypted" forKey:@"noteString"];

        NSError *error = nil;
        if (![_mContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        _detailText.text = @"Note has been encrypted";
        _encryptButton.title = @"Decrypt";
    } else {
        NSString *plaintext = [self decryptWithPrivateKey:[_detailItem valueForKey:@"cipherText"]];
        [self.detailItem setValue:plaintext forKey:@"noteString"];
        [self.detailItem setValue:nil forKey:@"cipherText"];

        NSError *error = nil;
        if (![_mContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        _detailText.text = plaintext;
        _encryptButton.title = @"Encrypt";
    }
}

- (void)generateKeyPairPlease
{
    OSStatus status = noErr;
    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init];
    // 2

    NSData * publicTag = [NSData dataWithBytes:publicKeyIdentifier
                                        length:strlen((const char *)publicKeyIdentifier)];
    NSData * privateTag = [NSData dataWithBytes:privateKeyIdentifier
                                         length:strlen((const char *)privateKeyIdentifier)];
    // 3

    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;                                // 4

    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA
                    forKey:(__bridge id)kSecAttrKeyType]; // 5
    [keyPairAttr setObject:[NSNumber numberWithInt:1024]
                    forKey:(__bridge id)kSecAttrKeySizeInBits]; // 6

    [privateKeyAttr setObject:[NSNumber numberWithBool:YES]
                       forKey:(__bridge id)kSecAttrIsPermanent]; // 7
    [privateKeyAttr setObject:privateTag
                       forKey:(__bridge id)kSecAttrApplicationTag]; // 8

    [publicKeyAttr setObject:[NSNumber numberWithBool:YES]
                      forKey:(__bridge id)kSecAttrIsPermanent]; // 9
    [publicKeyAttr setObject:publicTag
                      forKey:(__bridge id)kSecAttrApplicationTag]; // 10

    [keyPairAttr setObject:privateKeyAttr
                    forKey:(__bridge id)kSecPrivateKeyAttrs]; // 11
    [keyPairAttr setObject:publicKeyAttr
                    forKey:(__bridge id)kSecPublicKeyAttrs]; // 12

    status = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr,
                                &publicKey, &privateKey); // 13
    //    error handling...


    if(publicKey) CFRelease(publicKey);
    if(privateKey) CFRelease(privateKey);                       // 14
}

- (NSData *)encryptWithPublicKey:(NSData *)data
{
    uint8_t dataToEncrypt[[data length]];
    [data getBytes:dataToEncrypt];

    OSStatus status = noErr;

    size_t cipherBufferSize;
    uint8_t *cipherBuffer;                     // 1

    // [cipherBufferSize]
    size_t dataLength = sizeof(dataToEncrypt)/sizeof(dataToEncrypt[0]);

    SecKeyRef publicKey = NULL;                                 // 3

    NSData * publicTag = [NSData dataWithBytes:publicKeyIdentifier
                                        length:strlen((const char *)publicKeyIdentifier)]; // 4

    NSMutableDictionary *queryPublicKey =
    [[NSMutableDictionary alloc] init]; // 5

    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    // 6

    status = SecItemCopyMatching
    ((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKey); // 7

    //  Allocate a buffer

    cipherBufferSize = SecKeyGetBlockSize(publicKey);
    cipherBuffer = malloc(cipherBufferSize);

    //  Error handling

    if (cipherBufferSize < sizeof(dataToEncrypt)) {
        // Ordinarily, you would split the data up into blocks
        // equal to cipherBufferSize, with the last block being
        // shorter. For simplicity, this example assumes that
        // the data is short enough to fit.
        printf("Could not decrypt.  Packet too large.\n");
        return NULL;
    }

    // Encrypt using the public.
    status = SecKeyEncrypt(    publicKey,
                           kSecPaddingPKCS1,
                           dataToEncrypt,
                           (size_t) dataLength,
                           cipherBuffer,
                           &cipherBufferSize
                           );                              // 8

    //  Error handling
    //  Store or transmit the encrypted text

    if (publicKey) CFRelease(publicKey);

    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    free(cipherBuffer);

    return encryptedData;
}

- (NSString *)decryptWithPrivateKey: (NSData *)dataToDecrypt
{
    OSStatus status = noErr;

    size_t cipherBufferSize = [dataToDecrypt length];
    uint8_t *cipherBuffer = (uint8_t *)[dataToDecrypt bytes];

    size_t plainBufferSize;
    uint8_t *plainBuffer;

    SecKeyRef privateKey = NULL;

    NSData * privateTag = [NSData dataWithBytes:privateKeyIdentifier
                                         length:strlen((const char *)privateKeyIdentifier)];

    NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];

    // Set the private key query dictionary.
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    // 1

    status = SecItemCopyMatching
    ((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKey); // 2

    //  Allocate the buffer
    plainBufferSize = SecKeyGetBlockSize(privateKey);
    plainBuffer = malloc(plainBufferSize);

    if (plainBufferSize < cipherBufferSize) {
        // Ordinarily, you would split the data up into blocks
        // equal to plainBufferSize, with the last block being
        // shorter. For simplicity, this example assumes that
        // the data is short enough to fit.
        printf("Could not decrypt.  Packet too large.\n");
        return @"Error, packet too large.";
    }

    //  Error handling

    status = SecKeyDecrypt(    privateKey,
                           kSecPaddingPKCS1,
                           cipherBuffer,
                           cipherBufferSize,
                           plainBuffer,
                           &plainBufferSize
                           );                              // 3

    //  Error handling
    //  Store or display the decrypted text

    if(privateKey) CFRelease(privateKey);

    NSString *s = [[NSString alloc] initWithBytes:plainBuffer length:plainBufferSize encoding:NSUTF8StringEncoding];
    return s;
}


@end
