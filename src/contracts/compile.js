const fs = require('fs');
const solc = require('solc');

function myCompiler(solc, fileName, contractName, contractCode) {
    let input = {
        language: 'Solidity',
        sources: {
            [fileName]: {
                content: contractCode
            }
        },
        settings: {
            outputSelection: {
                '*': {
                    '*': ['*']
                }
            }
        }
    };

    let output = JSON.parse(solc.compile(JSON.stringify(input)));

    console.log("Compilation result: ",  output)

    let contract = output.contracts[fName][cName];

    if (contract) {
        let ABI = contract.abi;
        let bytecode = contract.evm.bytecode.object;

        fs.writeFileSync(__dirname + '\\' + cName + '.abi', JSON.stringify(ABI));
        fs.writeFileSync(__dirname + '\\' + cName + '.bin', bytecode);
    } else {
        console.log("Contract compilation failed.");
    }

    // console.log(ABI)
    // console.log(bytecode)

    fs.writeFileSync(__dirname + '\\' + contractName + '.abi', JSON.stringify(ABI))
    fs.writeFileSync(__dirname + '\\' + contractName + '.bin', bytecode)
}

let fName = "Marketplace.sol"
let cName = "NFTMarketplace"
let cCode = fs.readFileSync(__dirname + '\\' + fName, 'utf-8')


try {
    myCompiler(solc, fName, cName, cCode)
} catch (err) {
    console.log(err)

    // let solcx = solc.setupMethods(require('./soljson-v0.8.15+commit.e14f2714'))

    let compileVersion = "v0.8.20+commit.a1b79de6"
    solc.loadRemoteVersion(compileVersion, (err, solcSnapshot) => {
        if (err) {
            console.log(err)
        } else {
            myCompiler(solcSnapshot, fName, cName, cCode)
        }
    })
}
