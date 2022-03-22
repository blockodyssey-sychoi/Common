# Common Repo
Welcome! Here you can find some common Smart Contracts.
## ERC721_bys
A fork of ERC721 that allows to save gas on every transaction. <br>
Main optimizations:
- The balance of a user isn't saved directly in memory but calcolated from the  \_owners array!
- The \_mint function is designed for minting a certain amount of tokens natively.
- In the \_owners array, data is saved in a smart and gas-saving way! For every n tokens minted consecutively, only 1 piece of information will be written in the array.
- Token Supply integrated natively.
## Utils_bys
...
