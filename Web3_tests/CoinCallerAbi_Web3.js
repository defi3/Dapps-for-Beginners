
/// Starting from MetaCoin_Web3.js

const abi_ccabi = [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "balanceOf",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
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
		"name": "transfer",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
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
		"name": "transferFrom",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]

const address_ccabi = "0x52c2BC0f2c44312b9a8a105d6751aEc88CAFA6b3"

const contract_ccabi = new web3.eth.Contract(abi_ccabi, address_ccabi)


contract_MC.methods.balanceOf(account1).call((err, result) => { console.log(result) })		// 9810

contract_MC.methods.balanceOf(account2).call((err, result) => { console.log(result) })		// 110

contract_MC.methods.balanceOf(address_ccabi).call((err, result) => { console.log(result) })	// 0


web3.eth.getTransactionCount(account1, (err, txCount) => {

  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
    to: address_MC,
    data: contract_MC.methods.transfer(address_ccabi, 100).encodeABI()
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


contract_MC.methods.balanceOf(account1).call((err, result) => { console.log(result) })		// 9710

contract_MC.methods.balanceOf(account2).call((err, result) => { console.log(result) })		// 110

contract_MC.methods.balanceOf(address_ccabi).call((err, result) => { console.log(result) })	// 100


web3.eth.getTransactionCount(account1, (err, txCount) => {

  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
    to: address_ccabi,
    data: contract_ccabi.methods.transfer(account2, 10).encodeABI()
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


contract_MC.methods.balanceOf(account1).call((err, result) => { console.log(result) })		// 9710

contract_MC.methods.balanceOf(account2).call((err, result) => { console.log(result) })		// 120

contract_MC.methods.balanceOf(address_ccabi).call((err, result) => { console.log(result) })	// 90


web3.eth.getTransactionCount(account1, (err, txCount) => {

  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
    to: address_ccabi,
    data: contract_ccabi.methods.transferFrom(account1, account2, 10).encodeABI()
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
// err: Error: Returned error: VM Exception while processing transaction: revert CoinCallerAbi::transfer3: fail to call transferFrom


contract_ccabi.methods.balanceOf(account1).call((err, result) => { console.log(result) })	// 9710

contract_ccabi.methods.balanceOf(account2).call((err, result) => { console.log(result) })	// 120

contract_ccabi.methods.balanceOf(address_ccabi).call((err, result) => { console.log(result) })	// 90




