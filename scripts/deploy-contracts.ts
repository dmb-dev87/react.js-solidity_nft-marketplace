import { ethers } from 'hardhat'

async function main() {
  const BuddhaNFT = await ethers.getContractFactory("BuddhaNFT")
  console.log('Deploying BuddhaNFT...')
  const token = await BuddhaNFT.deploy("base_uri")

  await token.deployed()
  console.log("BuddhaNFT deployed to: ", token.address)

  const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace")
  console.log('Deploying NFTMarketplace...')
  const marketplace = await NFTMarketplace.deploy()

  await marketplace.deployed()
  console.log('NFTMarketplace deployed to: ', marketplace.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})