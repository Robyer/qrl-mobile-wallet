#include "wallet.h"
#include <stdint.h>

#include <qrl/xmssBase.h>
#include <qrl/xmssFast.h>
#include <shasha/shasha.h>
#include <qrl/hashing.h>
#include <PicoSHA2/picosha2.h>
#include <qrl/misc.h>
#include <qrl/xmssBasic.h>
#include <inttypes.h>
#include <string>
#include <syslog.h>
#include <kyber/ref/randombytes.h>
#include <sstream>

#ifdef __ANDROID__
#include <android/log.h>
#endif

using std::string;
using std::vector;

void platform_log(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
#ifdef __ANDROID__
    __android_log_vprint(ANDROID_LOG_VERBOSE, "ndk", fmt, args);
#else
    vprintf(fmt, args);
#endif
    va_end(args);
}

extern "C" __attribute__((visibility("default"))) __attribute((used))
const char* createWallet(int64_t treeHeight, int64_t hashFunction) {
    unsigned char seed_array[48];
    randombytes(seed_array, 48);
    std::vector<unsigned char> seed(seed_array, seed_array + sizeof seed_array / sizeof seed_array[0]);
    eHashFunction walletHashFunction;
    switch( (int)hashFunction) {
        case 1: {
            walletHashFunction = eHashFunction::SHAKE_128;
            break;
        }
        case 2: {
            walletHashFunction = eHashFunction::SHAKE_256;
            break;
        }
        case 3: {
            walletHashFunction = eHashFunction::SHA2_256;
            break;
        }
        default : {
            walletHashFunction = eHashFunction::SHAKE_128;
            break;
        }
    }
    XmssFast xmss = XmssFast(seed, treeHeight, walletHashFunction, eAddrFormatType::SHA256_2X);
    std::string result = bin2hstr(xmss.getExtendedSeed());
    result.append("||");
    std::string address = bin2hstr(xmss.getAddress());
    result.append(address);
    result.append("||");
    std::string xmsspk = bin2hstr(xmss.getPK());
    result.append(xmsspk);
    result.append("||");
    result.append(std::to_string(xmss.getHeight()));
    char* result_cstr = new char[result.length() + 1];
    std::strcpy(result_cstr, result.c_str());
    return result_cstr;
}

extern "C" __attribute__((visibility("default"))) __attribute((used))
const char* getMnemonic(char *hexSeed) {
    string hexSeedStr(hexSeed);
    QRLDescriptor desc = QRLDescriptor::fromExtendedSeed(hstr2bin(hexSeedStr));
    XmssFast xmss = XmssFast( hstr2bin(hexSeedStr.substr(6)), desc.getHeight(), desc.getHashFunction(), eAddrFormatType::SHA256_2X);
    std::string mnemonic = bin2mnemonic(xmss.getExtendedSeed());
    char* mnemonic_cstr = new char[mnemonic.length() + 1];
    std::strcpy(mnemonic_cstr, mnemonic.c_str());
    return mnemonic_cstr;
}

extern "C" __attribute__((visibility("default"))) __attribute((used))
const char* openWalletWithHexSeed(char *hexSeed) {
    string hexSeedStr(hexSeed);
    QRLDescriptor desc = QRLDescriptor::fromExtendedSeed(hstr2bin(hexSeedStr));
    XmssFast xmss = XmssFast( hstr2bin(hexSeedStr.substr(6)), desc.getHeight(), desc.getHashFunction(), eAddrFormatType::SHA256_2X);
    std::string result = bin2hstr(xmss.getExtendedSeed());
    result.append("||");
    std::string address = bin2hstr(xmss.getAddress());
    result.append(address);
    result.append("||");
    std::string xmsspk = bin2hstr(xmss.getPK());
    result.append(xmsspk);
    result.append("||");
    result.append(std::to_string(xmss.getHeight()));
    char* result_cstr = new char[result.length() + 1];
    std::strcpy(result_cstr, result.c_str());
    return result_cstr;
}

extern "C" __attribute__((visibility("default"))) __attribute((used))
const char* openWalletWithMnemonic(char *mnemonic) {
    string mnemonicStr(mnemonic);
    QRLDescriptor desc = QRLDescriptor::fromExtendedSeed(mnemonic2bin(mnemonicStr));
    XmssFast xmss = XmssFast( hstr2bin( bin2hstr(mnemonic2bin(mnemonicStr)).substr(6)), desc.getHeight(), desc.getHashFunction(), eAddrFormatType::SHA256_2X);
    std::string result = bin2hstr(xmss.getExtendedSeed());
    result.append("||");
    std::string address = bin2hstr(xmss.getAddress());
    result.append(address);
    result.append("||");
    std::string xmsspk = bin2hstr(xmss.getPK());
    result.append(xmsspk);
    result.append("||");
    result.append(std::to_string(xmss.getHeight()));
    char* result_cstr = new char[result.length() + 1];
    std::strcpy(result_cstr, result.c_str());
    return result_cstr;
}

extern "C" __attribute__((visibility("default"))) __attribute((used))
const char* isAddressValid(char *address) {
    string result;
    try {
        string addressStr(address);
        std::vector<uint8_t> addressBytes = hstr2bin(addressStr);
        if (addressBytes.size() != (QRLDescriptor::getSize() + ADDRESS_HASH_SIZE + 4))
            result = "invalid";
        else {
            auto descr = QRLDescriptor::fromBytes(
                    std::vector<uint8_t>(
                            addressBytes.cbegin(),
                            addressBytes.cbegin() + QRLDescriptor::getSize()));
            if (descr.getAddrFormatType() != eAddrFormatType::SHA256_2X) {
                result = "invalid";
            } else {
                std::vector<uint8_t> hashed_key2(ADDRESS_HASH_SIZE, 0);

                picosha2::hash256(addressBytes.cbegin(),
                                  addressBytes.cbegin() + QRLDescriptor::getSize() + ADDRESS_HASH_SIZE,
                                  hashed_key2.begin(), hashed_key2.end());

                if (addressBytes[35] == hashed_key2[28] &&
                    addressBytes[36] == hashed_key2[29] &&
                    addressBytes[37] == hashed_key2[30] &&
                    addressBytes[38] == hashed_key2[31]) {
                    result = "valid";
                } else {
                    result = "invalid";
                }
            }
        }
    } catch (...) {
        result = "invalid";
    }

    char* result_cstr = new char[result.length() + 1];
    std::strcpy(result_cstr, result.c_str());
    return result_cstr;
}

extern "C" __attribute__((visibility("default"))) __attribute((used))
const char* createTransaction(char *hexSeed, int64_t* amounts, char** receiverWalletAddresses, int transactionCount, int64_t otsIndex, int64_t fee, char *message, int messageType) {
    string hexSeedStr(hexSeed);

    string messageStr;
    int messageSize = 0;
    int messageVectorSize = 0;
    if (message != nullptr) {
        messageStr = string(message);
        messageSize = messageStr.length();
        if (messageType == 1) {
            messageVectorSize = messageSize;
        } else {
            messageVectorSize = messageSize / 2;
        }
    }
    std::vector<unsigned char> concatenatedVector((8 + messageVectorSize) + (47 * transactionCount));
    for (int i = 0; i < 8; i++) {
        concatenatedVector[7 - i] = (fee >> (i * 8));
    }

    int vectorPos = 8;

    if (messageSize > 0) {
        if (messageType == 1) {
            char messageBytes[messageSize];
            strcpy(messageBytes, messageStr.c_str());
            for (int count = 0; count < sizeof(messageBytes); count++) {
                concatenatedVector[vectorPos] = messageBytes[count];
                vectorPos++;
            }
        } else {
            char messageBytes[messageSize+1];
            strcpy(messageBytes, messageStr.c_str());
            char *messagePos = messageBytes;
            unsigned char val[messageSize / 2];
            for (int count = 0; count < (sizeof(messageBytes) / 2); count++) {
                sscanf(messagePos, "%2hhx", &val[count]);
                concatenatedVector[vectorPos] = val[count];
                messagePos += 2;
                vectorPos++;
            }
        }
    }

    for (int t = 0; t < transactionCount; t++) {
        string receiverWalletAddressStr(receiverWalletAddresses[t]);

        int nrec = receiverWalletAddressStr.length();
        char rechexBytes[nrec+1];
        strcpy(rechexBytes, receiverWalletAddressStr.c_str());
        char *recpos = rechexBytes;

        unsigned char val[39];
        for (int count = 0; count < (sizeof(rechexBytes) / 2); count++) {
            sscanf(recpos, "%2hhx", &val[count]);
            concatenatedVector[vectorPos] = val[count];
            recpos += 2;
            vectorPos++;
        }

        int vectorPos2 = 46 + ((8 + messageVectorSize) + (t * 47));
        for (int i = 0; i < 8; i++){
            concatenatedVector[vectorPos2 - i] = (amounts[t] >> (i * 8));
        }

        vectorPos = vectorPos2 + 1;
    }

    auto shaSum = sha2_256(concatenatedVector);

    int n = hexSeedStr.substr(6).length();
    char hexseedBytes[n+1];
    strcpy(hexseedBytes, hexSeedStr.substr(6).c_str());
    char *hexpos = hexseedBytes;

    std::vector<uint8_t> hexSeedVector(48);
    unsigned char hexval[48];
    for (int count = 0; count < (sizeof(hexseedBytes) / 2); count++) {
        sscanf(hexpos, "%2hhx", &hexval[count]);
        hexSeedVector[count] = (uint8_t) hexval[count];
        hexpos += 2;
    }

    QRLDescriptor desc = QRLDescriptor::fromExtendedSeed(hstr2bin(hexSeedStr));

    platform_log("HEIGHT : %i", desc.getHeight());
    platform_log("HASH FUNCTION : %i", desc.getHashFunction());
    XmssFast xmss_obj( hexSeedVector, desc.getHeight(), desc.getHashFunction(), eAddrFormatType::SHA256_2X);

    xmss_obj.setIndex(otsIndex);
    auto signature = xmss_obj.sign(shaSum);
    std::vector<unsigned char> concatenatedVectorTx = {};
    // append shaSum
    for(int i=0; i< shaSum.size(); i++){
        concatenatedVectorTx.push_back((uint8_t) shaSum[i]);
    }
    // append signature
    for(int i=0; i< signature.size(); i++){
        concatenatedVectorTx.push_back((uint8_t) signature[i]);
    }
    // append PK
    for(int i=0; i< xmss_obj.getPK().size() ; i++){
        concatenatedVectorTx.push_back((uint8_t) xmss_obj.getPK()[i]);
    }

    auto shaSumTx = sha2_256(concatenatedVectorTx);

    std::string data = bin2hstr(signature);
    data += bin2hstr(shaSumTx);
    char* data_cstr = new char[data.length() + 1];
    std::strcpy(data_cstr, data.c_str());
    return data_cstr;
}
