/* global ethereum */
/* eslint-disable */
import { createStore } from 'vuex'
import { ABI } from "@/contracts/TokenFactory.abi.js"
import { bytecode } from "@/contracts/TokenFactory.bin.js"


const ethers = require('ethers')
let provider = new ethers.providers.JsonRpcProvider("https://eth-sepolia.g.alchemy.com/v2/UqJsOz1IQnRrGqV9bh7Q7ziNR2rN7Pi7")

export default createStore({
    state: {
        address: "",
        chainId: "",
        chain: "",
        deployHash: "",
        contractAddress: "0xFaFF426CeF916f534d77F35eD314bEB688FFD1bC",
        isConnected: false, // Added to keep track of connection status
    },
    getters: {
    },
    mutations: {
    },
    actions: {
        async connectWallet({ state }) {
            // проверяем, что есть метамаск и подключаем его
            if (typeof window.ethereum !== 'undefined') {
                console.log("Ethereum client installed!")
                if (ethereum.isMetaMask === true) {
                    console.log("Metamask installed!")
                    if (ethereum.isConnected() !== true) {
                        console.log("Metamask is not connected!")
                        await ethereum.enable()
                        state.isConnected = true;
                        state.buttonText = 'Connected';
                    }
                    console.log("Metamask connected!")
                    state.isConnected = true;
                    state.buttonText = 'Connected';
                }
                else {
                    alert("Metamask is not installed!")
                    state.isConnected = false;
                }
            }
            else {
                alert("Ethereum client is not installed!")
            }

            provider = new ethers.providers.Web3Provider(ethereum)

            // подключаем аккаунт
            await ethereum.request({ method: "eth_requestAccounts" })
                .then(accounts => {
                    state.isConnected = true;
                    state.address = ethers.utils.getAddress(accounts[0])
                    state.signer = provider.getSigner()
                    console.log(`Account ${state.address} connected`)
                    alert("Connected!")
                })
            // получаем параметры сети 
            state.chainId = await window.ethereum.request({ method: 'eth_chainId' });
            console.log("chainId: ", state.chainId)
            if (state.chainId == "0x1") {
                state.chain = "mainnet"
            }
            else if (state.chainId == "0x5") {
                state.chain = "goerli"
                provider = new ethers.providers.JsonRpcProvider("https://eth-goerli.g.alchemy.com/v2/TS8hjejOOd_2UNj46exSTVtqS7-JxYrT")
                state.contest = new ethers.Contract(state.contractAddress, ABI, provider)
            }
            else if (state.chainId == "0x539") {
                state.chain = "ganache"
                provider = new ethers.providers.JsonRpcProvider("HTTP://127.0.0.1:7545")
                state.contest = new ethers.Contract(state.contractAddress, ABI, provider)
            }
            else if (state.chainId == "0x13881") {
                state.chain = "mumbai"
                provider = new ethers.providers.JsonRpcProvider("https://polygon-mumbai.g.alchemy.com/v2/wusrTgSFSsScFKTK6Nqa5rFoisfYXjPW")
                state.contest = new ethers.Contract(state.contractAddress, ABI, provider)
            }
            else if (state.chainId == "0xaa36a7") {
                state.chain = "sepolia"
                provider = new ethers.providers.JsonRpcProvider("https://eth-sepolia.g.alchemy.com/v2/UqJsOz1IQnRrGqV9bh7Q7ziNR2rN7Pi7")
                state.contest = new ethers.Contract(state.contractAddress, ABI, provider)
            }

            ethereum.on('accountsChanged', (accounts) => {
                state.isConnected = true;
                state.address = ethers.utils.getAddress(accounts[0])
                state.signer = provider.getSigner()
                console.log(`accounts changed to ${state.address}`)
            })

            ethereum.on('chainChanged', async (chainId) => {
                // создаём провайдера
                provider = new ethers.providers.Web3Provider(ethereum)
                // получаем параметры сети 
                state.chainId = await window.ethereum.request({ method: 'eth_chainId' });
                console.log(`chainId changed to ${state.chainId}`)

                if (state.chainId == "0x1") {
                    state.chain = "mainnet"
                    alert(`chain changed to ${state.chain}`)
                }
                else if (state.chainId == "0x5") {
                    state.chain = "goerli"
                    provider = new ethers.providers.JsonRpcProvider("https://eth-goerli.g.alchemy.com/v2/TS8hjejOOd_2UNj46exSTVtqS7-JxYrT")
                    alert(`chain changed to ${state.chain}`)

                }
                else if (state.chainId == "0x539") {
                    state.chain = "ganache"
                    provider = new ethers.providers.JsonRpcProvider("HTTP://127.0.0.1:7545")
                    alert(`chain changed to ${state.chain}`)

                }
                else if (state.chainId == "0x13881") {
                    state.chain = "mumbai"
                    provider = new ethers.providers.JsonRpcProvider("https://polygon-mumbai.g.alchemy.com/v2/wusrTgSFSsScFKTK6Nqa5rFoisfYXjPW")
                    alert(`chain changed to ${state.chain}`)
                }
                else if (state.chainId == "0xaa36a7") {
                    state.chain = "sepolia"
                    provider = new ethers.providers.JsonRpcProvider("https://eth-sepolia.g.alchemy.com/v2/UqJsOz1IQnRrGqV9bh7Q7ziNR2rN7Pi7")
                    alert(`chain changed to ${state.chain}`)
                }
            })
        },
        async createERC20Token({ state }, args) {
            const [name, symbol, initialSupply] = args;
            const iContract = new ethers.utils.Interface(ABI);
    
            const data = iContract.encodeFunctionData("createERC20Token", [name, symbol, initialSupply]);
    
            try {
                const txHash = await window.ethereum.request({
                    method: "eth_sendTransaction",
                    params: [{
                        from: state.address,
                        to: state.contractAddress,
                        data: data
                    }]
                });
                console.log(`Tx hash: ${txHash}`);
                return txHash;
            } catch (error) {
                console.error("Transaction declined by user", error);
                throw new Error("Transaction declined by user.");  // Propagate the error message
            }
        },
        async createERC721Token({ state }, args) {
            const [name, symbol] = args;
            const iContract = new ethers.utils.Interface(ABI);
    
            const data = iContract.encodeFunctionData("createERC721Token", [name, symbol]);
    
            try {
                const txHash = await window.ethereum.request({
                    method: "eth_sendTransaction",
                    params: [{
                        from: state.address,
                        to: state.contractAddress,
                        data: data
                    }]
                });
                console.log(`Tx hash: ${txHash}`);
                return txHash;
            } catch (error) {
                console.error("Transaction declined by user", error);
                throw new Error("Transaction declined by user.");  // Propagate the error message
            }
        }
    },
    modules: {
    }
})
