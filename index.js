
const cron = require('node-cron');
const Web3 = require("web3");
const HDWalletProvider = require("@truffle/hdwallet-provider");
require('dotenv').config()

const { listen } = require('./scripts/hunt');
const addresses = require('./scripts/common/addresses');

const network = process.env.NETWORK || 'kovan';

let provider = new HDWalletProvider(process.env.MNEMONIC_OR_KEY, `https://${network}.infura.io/v3/${process.env.INFURA_ID}`);
const web3 = new Web3(provider);

const contractAddresses = addresses[network];

let world = {};    // global object
world.web3 = web3;
world.contractAddresses = contractAddresses;

const start = async () => {
  try {
    world.accounts = await web3.eth.getAccounts();

    world.txIssuerWallet = web3.eth.accounts.privateKeyToAccount(process.env.PRIVATEKEY);
    world.txIssuerWallet.nonce = await web3.eth.getTransactionCount(world.txIssuerWallet.address, 'pending');

    listen(world)    // for testing
    // startCron();
  } catch (error) {
    console.error(error);
  }
}
start();

const startCron = () => {
  cron.schedule('*/3 * * * * *', () => {
    listen(world)
      .catch((error) => {
        console.error(error);
      });
  });
}
