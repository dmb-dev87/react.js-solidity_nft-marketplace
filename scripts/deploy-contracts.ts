import { ethers } from 'hardhat'

async function main() {
  const baseTokenURI = "ipfs://QmW2zHyJDpvbcoShcWqMwvuZRzzuSQY6eHZ8fXGcRCtuKz/";

  const BuddhaNFT = await ethers.getContractFactory("BuddhaNFT");
  const buddhaNft = await BuddhaNFT.deploy(baseTokenURI);
  await buddhaNft.deployed();

  console.log("BuddhaNFT deployed to:", buddhaNft.address);

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