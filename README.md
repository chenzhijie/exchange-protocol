## Decentralized Ethereum Assets Exchange Protocol

### Description
This protocol is use for exchange assets. The exchange process has only three phase: 

1. **Deposit phase:** Buyer and seller deposit their ethereum assets to the contract. Including ether and all the erc20 token. The contract will return a unique exchange id .
2. **Bind phase:** They need to bind the exchange id. Both of them, need to update the exchange information, adding a receiver exchange id, the receiver address.And the most important is the assets owner need to lock it with a custom key.
3. **Withdraw phase:** After they confirm the exchange is bind sucessfully and accurately. One of them can tell the receiver his key. Don't worry the contract will make sure the assets exchange happened. This phase only leads to one of the following two results. 

	**A. The use withdraw their assets back respectively.**
	
	**B. They exchange their assets.**
		
### Install

	git clone https://github.com/chenzhijie/exchange-protocol.git
	truffle compile && truffle migrate --reset
	truffle console
	
	
### To-do
1. Build user interface web app with this protocol.
2. Ethereum assets mobile wallet.