const Web3 = require('web3')

const web3 = new Web3('https://http-mainnet.hecochain.com')

const ROUTER_ABI= require('./abis/router_abi.json')
const ROUTER_CONTRACT_ADDR = web3.utils.toChecksumAddress('0xed7d5f38c79115ca12fe6c0041abb22f0a06c300')
const ROUTER = new web3.eth.Contract(ROUTER_ABI, ROUTER_CONTRACT_ADDR)

const SWAP_ABI = require('./abis/swap_mining_abi.json')
const SWAP_CONTRACT_ADDR = web3.utils.toChecksumAddress('0x7373c42502874C88954bDd6D50b53061F018422e')
const SWAP = new web3.eth.Contract(SWAP_ABI, SWAP_CONTRACT_ADDR)

const HUSDUSDT_PID = 3

getUserReward()

async function getUserReward() {
    let result = await SWAP.methods.getUserReward(HUSDUSDT_PID).call()
    console.log(result)
}

async function querySwapMining() {
    let result = await ROUTER.methods.swapMining().call()
    console.log(result)
}