// Name Registration with Notary
//
// USAGE
//     If not registered yet, register name; otherwise return timestamp:
//         send(NameRegNotaryAddr, "MyDAppName", valueInWei)
//     Unregister (only works if sent from original registered address):
//         send(NameRegNotaryAddr, valueInWei)
//
// Should be backwards compatible with NameReg -- the only difference is 
// that it returns a timestamp if you try to register an already registered 
// name.
//
// Derived from NameReg, which was taken from: 
//     https://github.com/ethereum/cpp-ethereum/wiki/LLL-Examples-for-PoC-5


// Initialize
thisName := "NameRegNotary"
contract.storage[contract.address] = thisName
contract.storage[thisName] = contract.address
contract.storage[sha3(thisName)] = tx.timestamp
contract.storage[69] = tx.origin()

// Also register with (the original) NameReg contract
[0] @thisName  // How to convert "[0]" from LLL to Mutan???
call(100-gas, 0x2d0aceee7e5ab874e22ccf8d1a649f59106d74e8, 0, 0, 13, 0, 0)


// Body of contract
exit compile {
    // The first argument (name) exists
    if tx.dataSize {

        if contract.storage[this.data[0]] {
            // First arg is already registered, return timestamp.
            return contract.storage[sha3(this.data[0])]

            // Name is not registered, so 
            // store sender at name, and name at sender.
            if contract.storage[tx.origin()] {
                contract.storage[contract.storage[tx.origin()]] = 0
            }
            [[(calldataload 0)]] (caller)
            [[(caller)]] (calldataload 0)
            (stop)
        }

        // No arguments - either unregister or suicide if from owner.
        {
            // Suicide if it's from owner's address.
            (when (= (caller) @@69) (suicide (caller)))

            // Otherwise, unregister name.
            (when @@(caller) {
                [[@@(caller)]] 0
                [[(caller)]] 0
            })
            (stop)
        }

    }
}

