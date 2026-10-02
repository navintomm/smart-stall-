#include "BleServerHandler.h"
#include "Logger.h"
#include "ProtocolCodec.h"
#include "CommandDispatcher.h"
#include "SystemHealthManager.h"
#include "hardware/EmergencyController.h"

#define SERVICE_UUID           "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_TX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

BLEServer* BleServerHandler::pServer = nullptr;
BLECharacteristic* BleServerHandler::pTxCharacteristic = nullptr;
bool BleServerHandler::deviceConnected = false;
bool BleServerHandler::oldDeviceConnected = false;
String BleServerHandler::rxBuffer = "";
unsigned long BleServerHandler::lastHeartbeatTime = 0;

class BleServerHandler::ServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        deviceConnected = true;
        lastHeartbeatTime = millis();
        Logger::info("BLE", "Device connected");
    }

    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
        Logger::critical("BLE", "Device disconnected");
        if (!EmergencyController::isEmergency()) {
            Logger::critical("BLE", "Triggering EMERGENCY STOP due to BLE disconnect.");
            EmergencyController::triggerEmergencyStop();
        }
    }
};

class BleServerHandler::RxCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        String rxValue = pCharacteristic->getValue().c_str();
        
        if (rxValue.length() > 0) {
            for (int i = 0; i < rxValue.length(); i++) {
                char c = rxValue[i];
                if (c == '\n') {
                    if (rxBuffer.length() > 0) {
                        processIncomingLine(rxBuffer);
                        rxBuffer = "";
                        lastHeartbeatTime = millis(); // heartbeat on valid frame
                    }
                } else if (c != '\r') {
                    rxBuffer += c;
                    if (rxBuffer.length() > 2048) {
                        rxBuffer = "";
                        Logger::warning("BLE", "Buffer overflow, dropping data.");
                    }
                }
            }
        }
    }
};

void BleServerHandler::init() {
    BLEDevice::init("SmartStall-ESP32");
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new ServerCallbacks());

    BLEService *pService = pServer->createService(SERVICE_UUID);

    pTxCharacteristic = pService->createCharacteristic(
                                        CHARACTERISTIC_UUID_TX,
                                        BLECharacteristic::PROPERTY_NOTIFY
                                    );
    pTxCharacteristic->addDescriptor(new BLE2902());

    BLECharacteristic *pRxCharacteristic = pService->createCharacteristic(
                                            CHARACTERISTIC_UUID_RX,
                                            BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR
                                        );
    pRxCharacteristic->setCallbacks(new RxCallbacks());

    pService->start();
    
    // Start advertising
    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->setMinPreferred(0x06);  
    pAdvertising->setMinPreferred(0x12);
    BLEDevice::startAdvertising();
    Logger::info("BLE", "BLE Server Initialized and Advertising.");
}

void BleServerHandler::tick() {
    if (deviceConnected) {
        // Enforce 3s heartbeat timeout just like WifiServerHandler
        if (millis() - lastHeartbeatTime > 3000) {
            if (!EmergencyController::isEmergency()) {
                Logger::critical("BLE", "Client heartbeat timeout! Triggering EMERGENCY STOP.");
                EmergencyController::triggerEmergencyStop();
            }
            // Disconnect the client to force a fresh reconnect
            if (pServer->getConnectedCount() > 0) {
                pServer->disconnect(pServer->getConnId());
            }
        }
    }
    
    // Handle disconnections
    if (!deviceConnected && oldDeviceConnected) {
        delay(500); // Give the bluetooth stack the chance to get things ready
        pServer->startAdvertising(); // restart advertising
        Logger::info("BLE", "Advertising restarted");
        oldDeviceConnected = deviceConnected;
    }
    
    // Handle new connections
    if (deviceConnected && !oldDeviceConnected) {
        oldDeviceConnected = deviceConnected;
    }
}

void BleServerHandler::processIncomingLine(const String& line) {
    RobotPacket packet;
    if (ProtocolCodec::decode(line.c_str(), packet)) {
        SystemHealthManager::petWatchdog();

        if (packet.type == "command") {
            CommandDispatcher::handleCommand(packet);
        }
    }
}

void BleServerHandler::sendData(const String& data) {
    if (deviceConnected && pTxCharacteristic != nullptr) {
        pTxCharacteristic->setValue((uint8_t*)data.c_str(), data.length());
        pTxCharacteristic->notify();
    }
}
