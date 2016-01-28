//
//  ViewController.m
//  BLECentral
//
//  Created by Matthias Uttendorfer on 28/01/16.
//  Copyright © 2016 Matthias Uttendorfer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic ,strong) CBCentralManager *central;
@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;
@property (nonatomic, strong) CBCharacteristic *notifyCharacteristic;
@end

@implementation ViewController

- (IBAction)sendData:(UIButton *)sender {
    if (self.writeCharacteristic) {
        [self.peripheral writeValue:[@"writeRequest" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.central = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self.central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FF10"]]
                                             options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @(NO)}];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if ([advertisementData[CBAdvertisementDataLocalNameKey] isEqualToString: @"peripheral"]) {
        
        NSLog(@"found peripheral");
        self.peripheral = peripheral;
        [self.peripheral setDelegate:self];
        [self.central connectPeripheral:self.peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"did connect to peripheral");
    [self.peripheral discoverServices:@[[CBUUID UUIDWithString:@"FF10"]]];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"did disconnect to peripheral");
}

#pragma mark - Peripheral Delegates 

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
 
    for (CBService *service in peripheral.services) {
        [self.peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    if ([service.UUID isEqual: [CBUUID UUIDWithString:@"FF10"]]) {
        
        for (CBCharacteristic *chara in [service characteristics]) {
            if ([chara.UUID isEqual:[CBUUID UUIDWithString:@"FF20"]]) {
                self.writeCharacteristic = chara;
            }
            if ([chara.UUID isEqual:[CBUUID UUIDWithString:@"FF30"]]) {
                self.notifyCharacteristic = chara;
               [self.peripheral setNotifyValue:YES forCharacteristic:self.notifyCharacteristic];
            }
        }

    }
        NSLog(@"finished discovery");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"did write value : %@" , [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (characteristic == self.notifyCharacteristic) {
        NSLog(@"peripheral did update value : %@" , [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
    }
}
@end
