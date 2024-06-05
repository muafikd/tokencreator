const fs = require('fs');
const solc = require('solc');

function myCompiler(solc, fileName, contractName, contractCode){
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

    //console.log("Compilation result: ",  output.contracts[fileName])

    let ABI = output.contracts[fileName][contractName].abi
    let bytecode = output.contracts[fileName][contractName].evm.bytecode.object
    
    // console.log(ABI)
    // console.log(bytecode)

    fs.writeFileSync(__dirname + '\\' + contractName + '.abi', JSON.stringify(ABI))
    fs.writeFileSync(__dirname + '\\' + contractName + '.bin', bytecode)
}

let fName = "TokenCreator.sol"
let cName = "TokenFactory"
let cCode = fs.readFileSync(__dirname + '\\' + fName, 'utf-8')


try{
    myCompiler(solc, fName, cName, cCode)
}catch(err){
    console.log(err)

    // let solcx = solc.setupMethods(require('./soljson-v0.8.15+commit.e14f2714'))

    let compileVersion = "v0.8.20+commit.a1b79de6"
    solc.loadRemoteVersion(compileVersion, (err, solcSnapshot) => {
        if(err){
            console.log(err)
        }else{
            myCompiler(solcSnapshot, fName, cName, cCode)
        }
    })
}
