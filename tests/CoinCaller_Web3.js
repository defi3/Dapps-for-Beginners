
/// include metaCoin_Web3.js

const abi_coinCaller = [
	{
		"constant": false,
		"inputs": [
			{
				"internalType": "address",
				"name": "coinContractAddress",
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
	}
]

const address_coinCaller = "0xc323EE368Fb877C918E94fE195f064025c586429"

const contract_coinCaller = new web3.eth.Contract(abi_coinCaller, address_coinCaller)


contract_metaCoin.methods.balances(account1).call((err, result) => { console.log(result) })	// 9910

contract_metaCoin.methods.balances(account2).call((err, result) => { console.log(result) })	// 90


web3.eth.getTransactionCount(account1, (err, txCount) => {

  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
    to: address_coinCaller,
    data: contract_coinCaller.methods.sendCoin(address_metaCoin, account2, 50).encodeABI()
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

// err: null txHash: 0x48349aeb3f6485ce4e28524890c0543a07a1310e69786f951f831cb25840f4b1


contract_metaCoin.methods.balances(account1).call((err, result) => { console.log(result) })	// 9860

contract_metaCoin.methods.balances(account2).call((err, result) => { console.log(result) })	// 140


web3.eth.getTransactionCount(account2, (err, txCount) => {

  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
    to: address_coinCaller,
    data: contract_coinCaller.methods.sendCoin(address_metaCoin, account1, 5).encodeABI()
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

// err: null txHash: 0xcdbbbb357ffd81c5d0474c921fb8c3a3eeb6afa517c3beca54b7b468a1af0079


contract_metaCoin.methods.balances(account1).call((err, result) => { console.log(result) })	// 9865

contract_metaCoin.methods.balances(account2).call((err, result) => { console.log(result) })	// 135
