const Web3 = require('web3');
var contract = require("truffle-contract");
var contractJson = require("./build/contracts/ExchangeProtocol.json");
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
var ExchangeProtocol = contract(contractJson);
ExchangeProtocol.setProvider(web3.currentProvider);
const ExchangeProtocolAddr = '0x4cf47673018a60959275208bca99d5e8e25cdd82'


//0x1075342d611214aa5931950c944b18f584f2c27f88ecd0aae1c414d8179042dd
const TransferEthToContract = async (dex)=> {
    const protocolAddr = dex.address
    const acc = web3.eth.accounts[0]
    web3.eth.defaultAccount = acc
    console.log('before sendTransaction', web3.eth.getBalance(acc).toString(), web3.eth.getBalance(protocolAddr).toString()) 
    await web3.eth.sendTransaction({from:acc, to:protocolAddr, value: web3.toWei(1, 'ether'), gas: 3141592 })
    console.log('after sendTransaction', web3.eth.getBalance(acc).toString(), web3.eth.getBalance(protocolAddr).toString()) 
}

const TransferTokenToContract = async (dex) => {
    const protocolAddr = dex.address
    const acc = web3.eth.accounts[0]
    web3.eth.defaultAccount = acc
    await dex.depositToken('0x677fd95ef22ae7fe67dbd54283d2edc8b59113b5', 1000000000000000000)
}

function UpdateSenderInfo() {

}

function UpdateReceiverInfo() {

}

function Withdraw() {

}

ExchangeProtocol.at(ExchangeProtocolAddr).then( async (dex) => {
  
    try {
        // TransferEthToContract(dex)
        TransferTokenToContract(dex)
        // await dex.updateExchange('0x79c3a366ebf8b49d9f0ca7a2323fb10699e155419850a68f1cffab0a8964235b', web3.eth.accounts[1], '0x276428be1f4c9950e9e8a30f2c75c0d7e1d0c1499f623a7295835d60641ac92c', "123456")
        // const result = await dex.getExsAt(0)
        // dex.withdraw('0x79c3a366ebf8b49d9f0ca7a2323fb10699e155419850a68f1cffab0a8964235b', '123456')
        // console.log(result)
    } catch (e) {
        console.log('err', e)
    }
    dex.Log ().watch ( (err, response) => {  
        if (!err) {
            console.log('\ntag= ',response.args.tag)
            console.log('receiver= ', response.args.receiver)
            console.log('id = ', response.args.exchangeId)
            console.log('toid = ', response.args.toExchangeId)
        } else {
            console.log('err', err)
        }
    });
    dex.Deposit ().watch ( (err, response) => {  
        if (!err) {
            console.log('sender= ',response.args.sender)
            console.log('amount= ', response.args.amount.toString())
            console.log('id = ', response.args.exchangeId)
        } else {
            console.log('err', err)
        }
    });
    dex.Withdraw ().watch ( (err, response) => {  
        if (!err) {
            console.log('receiver= ',response.args.receiver)
            console.log('amount= ', response.args.amount.toString())
            console.log('id = ', response.args.exchangeId)
        } else {
            console.log('err', err)
        }
    });

    dex.Debug ().watch ( (err, response) => {  
        if (!err) {
            console.log('line= ',response.args.line)
            console.log('content= ', response.args.content)
            console.log('addr = ', response.args.addr)
        } else {
            console.log('err', err)
        }
    });


})
