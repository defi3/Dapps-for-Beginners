
const Web3 = require('web3');

const web3 = new Web3('http://localhost:7545');


const account1 = "0xEcE0e332d2682785B33a9E02CF5f0385897FE37D"

const privateKey1 = Buffer.from('a8ece028f8a0e621ae425f175c059abe57cf2414570bc954478f9a651ec02113', 'hex')


const abi_dc = [
	{
		"constant": false,
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_a",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_s",
				"type": "string"
			}
		],
		"name": "set2",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_a",
				"type": "uint256"
			}
		],
		"name": "setA",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"internalType": "string",
				"name": "_s",
				"type": "string"
			}
		],
		"name": "setS",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "a",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "s",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	}
]

const address_dc = "0x984Ef98F460B1b7e5C5747214373B13BEAc5f095"

const contract_dc = new web3.eth.Contract(abi_dc, address_dc)


contract_dc.methods.a().call((err, result) => { console.log(result) })		// 1

contract_dc.methods.s().call((err, result) => { console.log(result) })		// a


contract_dc.methods.setA(2).call((err, result) => { console.log(result) })	// 2

contract_dc.methods.a().call((err, result) => { console.log(result) })		// 1  (does not work)


var Tx = require('ethereumjs-tx').Transaction

web3.eth.getTransactionCount(account1, (err, txCount) => {

  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
    to: address_dc,
    data: contract_dc.methods.setA(2).encodeABI()
  }

  const tx = new Tx(txObject)
  tx.sign(privateKey1)

  const serializedTx = tx.serialize()
  const raw = '0x' + serializedTx.toString('hex')

  web3.eth.sendSignedTransaction(raw, (err, txHash) => {
    console.log('err:', err, 'txHash:', txHash)
    // Use this txHash to find the contract on Etherscan!
  })
})

contract_dc.methods.a().call((err, result) => { console.log(result) })		// 2


web3.eth.getTransactionCount(account1, (err, txCount) => {

  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
    to: address_dc,
    data: contract_dc.methods.setS("ab").encodeABI()
  }

  const tx = new Tx(txObject)
  tx.sign(privateKey1)

  const serializedTx = tx.serialize()
  const raw = '0x' + serializedTx.toString('hex')

  web3.eth.sendSignedTransaction(raw, (err, txHash) => {
    console.log('err:', err, 'txHash:', txHash)
    // Use this txHash to find the contract on Etherscan!
  })
})

contract_dc.methods.s().call((err, result) => { console.log(result) })		// ab


web3.eth.getTransactionCount(account1, (err, txCount) => {

  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
    to: address_dc,
    data: contract_dc.methods.set2(3, "abc").encodeABI()
  }

  const tx = new Tx(txObject)
  tx.sign(privateKey1)

  const serializedTx = tx.serialize()
  const raw = '0x' + serializedTx.toString('hex')

  web3.eth.sendSignedTransaction(raw, (err, txHash) => {
    console.log('err:', err, 'txHash:', txHash)
    // Use this txHash to find the contract on Etherscan!
  })
})

contract_dc.methods.a().call((err, result) => { console.log(result) })		// 3

contract_dc.methods.s().call((err, result) => { console.log(result) })		// abc


const abi_cc = [
	{
		"constant": false,
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_a",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_s",
				"type": "string"
			}
		],
		"name": "set2",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_a",
				"type": "uint256"
			}
		],
		"name": "setA",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"internalType": "string",
				"name": "_s",
				"type": "string"
			}
		],
		"name": "setS",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_t",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	}
]

const address_cc = "0xa18C322aF0fDbB5048B279A55266906Ed58eC7d6"

const contract_cc = new web3.eth.Contract(abi_cc, address_cc)


web3.eth.getTransactionCount(account1, (err, txCount) => {

  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
    to: address_dc,
    data: contract_cc.methods.set2(5, "abcde").encodeABI()
  }

  const tx = new Tx(txObject)
  tx.sign(privateKey1)

  const serializedTx = tx.serialize()
  const raw = '0x' + serializedTx.toString('hex')

  web3.eth.sendSignedTransaction(raw, (err, txHash) => {
    console.log('err:', err, 'txHash:', txHash)
    // Use this txHash to find the contract on Etherscan!
  })
})

contract_dc.methods.a().call((err, result) => { console.log(result) })		// 5

contract_dc.methods.s().call((err, result) => { console.log(result) })		// abcde


