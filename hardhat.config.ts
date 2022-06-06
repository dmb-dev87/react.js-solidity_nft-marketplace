import * as dotenv from 'dotenv'
import { task } from 'hardhat/config'
import '@nomiclabs/hardhat-waffle'
import '@nomiclabs/hardhat-etherscan'
import '@typechain/hardhat'

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

module.exports = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      rul: process.env.RINKEBY_URL || '',
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
}
