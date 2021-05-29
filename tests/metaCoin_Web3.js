
const Web3 = require('web3');

const web3 = new Web3('http://localhost:7545');


const account1 = "0xEcE0e332d2682785B33a9E02CF5f0385897FE37D"

const account2 = "0x2c65B57b133CB5D6Db904d65A9DC8882eeeF6991"

const privateKey1 = Buffer.from('a8ece028f8a0e621ae425f175c059abe57cf2414570bc954478f9a651ec02113', 'hex')

const privateKey2 = Buffer.from('9047e7bc033d4b9406ea18aecf1e6c83e7c441af43006f33c2b99e3d91fb041e', 'hex')


const abi_metaCoin = [
	{
		"constant": false,
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "receiver",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "sendCoin",
		"outputs": [
			{
				"internalType": "int8",
				"name": "result",
				"type": "int8"
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
				"internalType": "address",
				"name": "receiver",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "sendCoin",
		"outputs": [
			{
				"internalType": "int8",
				"name": "result",
				"type": "int8"
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
				"name": "account",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"constant": true,
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "balances",
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
		"name": "totalSupply",
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
	}
]

const address_metaCoin = "0xBF559b0b014941368b5869454C17886E42AdDbD9"

const contract_metaCoin = new web3.eth.Contract(abi_metaCoin, address_metaCoin)


contract_metaCoin.methods.totalSupply().call((err, result) => { console.log(result) })		// 10000

contract_metaCoin.methods.balances(account1).call((err, result) => { console.log(result) })	// 10000

contract_metaCoin.methods.balances(account2).call((err, result) => { console.log(result) })	// 0


var Tx = require('ethereumjs-tx').Transaction

web3.eth.getTransactionCount(account1, (err, txCount) => {

  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
    to: address_metaCoin,
    data: contract_metaCoin.methods.sendCoin(account2, 100).encodeABI()
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

// err: null txHash: 0x133536299dde3fbb200f8165dc39ffccea7950895fd1e23e0807426fb3fc479b


contract_metaCoin.methods.balances(account1).call((err, result) => { console.log(result) })	// 9900

contract_metaCoin.methods.balances(account2).call((err, result) => { console.log(result) })	// 100


web3.eth.getTransactionCount(account2, (err, txCount) => {

  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
    to: address_metaCoin,
    data: contract_metaCoin.methods.sendCoin(account2, account1, 10).encodeABI()
  }

  const tx = new Tx(txObject)
  tx.sign(privateKey2)

  const serializedTx = tx.serialize()
  const raw = '0x' + serializedTx.toString('hex')

  web3.eth.sendSignedTransaction(raw, (err, txHash) => {
    console.log('err:', err, 'txHash:', txHash)
    // Use this txHash to find the contract on Etherscan!
  })
})

// err: null txHash: 0x4690c98995fc8a4aab259caa0ef14ad75482e90a63fc02a2384da0566ea1b62e


contract_metaCoin.methods.balances(account1).call((err, result) => { console.log(result) })	// 9910

contract_metaCoin.methods.balances(account2).call((err, result) => { console.log(result) })	// 90
