#ifndef WALLET_H
#define WALLET_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

extern void platform_log(const char *fmt, ...);

extern const char* createWallet(int64_t treeHeight, int64_t hashFunction);

extern const char* getMnemonic(char *hexSeed);

extern const char* openWalletWithHexSeed(char *hexSeed);

extern const char* openWalletWithMnemonic(char *mnemonic);

extern const char* isAddressValid(char *address);

extern const char* createTransaction(char *hexSeed, int64_t* amounts, char** receiverWalletAddresses, int transactionCount, int64_t otsIndex, int64_t fee);

#ifdef __cplusplus
}
#endif

#endif
