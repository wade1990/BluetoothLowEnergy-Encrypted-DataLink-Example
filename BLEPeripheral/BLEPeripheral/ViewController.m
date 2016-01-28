//
//  ViewController.m
//  BLEPeripheral
//
//  Created by Matthias Uttendorfer on 28/01/16.
//  Copyright © 2016 Matthias Uttendorfer. All rights reserved.
//

#import "ViewController.h"


@interface ViewController () <CBPeripheralManagerDelegate>

@property (nonatomic ,strong) CBPeripheralManager *peripheral;
@property (nonatomic, strong) CBMutableService *service;

@property (nonatomic, strong) CBMutableCharacteristic *writeCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *notifyCharacteristic;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peripheral = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [self setup];
        
    }
    
}

- (void)setup {
    
    
    
    self.service = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:@"FF10"] primary:YES];
    
    self.writeCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"FF20"]
                                                                 properties:CBCharacteristicPropertyWrite
                                                                      value:nil
                                                                permissions:CBAttributePermissionsWriteEncryptionRequired];
    
    self.notifyCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"FF30"]
                                                                 properties:CBCharacteristicPropertyNotifyEncryptionRequired
                                                                      value:nil
                                                                permissions:CBAttributePermissionsReadEncryptionRequired];
    
    [self.service setCharacteristics:@[self.notifyCharacteristic , self.writeCharacteristic]];
    
    [self.peripheral addService:self.service];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    
    [self.peripheral startAdvertising:@{CBAdvertisementDataLocalNameKey : @"peripheral"  , CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:@"FF10"]]}];
    
}

-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"did start advertising");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"central did subscribe to notify characteristic");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    
    NSLog(@"did received read request");
    [self.peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    
    for (CBATTRequest *currentRequest in requests) {
        [self.writeCharacteristic setValue:currentRequest.value];
        [self.peripheral respondToRequest:currentRequest withResult:CBATTErrorSuccess];
        [self.peripheral updateValue:[@"notifyRequest" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.notifyCharacteristic onSubscribedCentrals:nil];
    }
    
}

@end
