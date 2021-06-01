
/// Starting from MetaCoin_Web3.js

const abi_cc = [
	{
		"constant": false,
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
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
		"name": "transfer",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	}
]

const address_cc = "0x96b9b61D75d27Cd5ed61f86eE78F0c6307C3FF0c"

const contract_cc = new web3.eth.Contract(abi_cc, address_cc)


contract_MC.methods.balanceOf(account1).call((err, result) => { console.log(result) })		// 9910

contract_MC.methods.balanceOf(account2).call((err, result) => { console.log(result) })		// 90

contract_MC.methods.balanceOf(address_cc).call((err, result) => { console.log(result) })	// 0


web3.eth.getTransactionCount(account1, (err, txCount) => {

  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
    to: address_MC,
    data: contract_MC.methods.transfer(address_cc, 100).encodeABI()
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


contract_MC.methods.balanceOf(account1).call((err, result) => { console.log(result) })		// 9810

contract_MC.methods.balanceOf(account2).call((err, result) => { console.log(result) })		// 90

contract_MC.methods.balanceOf(address_cc).call((err, result) => { console.log(result) })	// 100


web3.eth.getTransactionCount(account1, (err, txCount) => {

  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
    to: address_cc,
    data: contract_cc.methods.transfer(address_MC, account2, 10).encodeABI()
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


contract_MC.methods.balanceOf(account1).call((err, result) => { console.log(result) })		// 9810

contract_MC.methods.balanceOf(account2).call((err, result) => { console.log(result) })		// 100

contract_MC.methods.balanceOf(address_cc).call((err, result) => { console.log(result) })	// 90


