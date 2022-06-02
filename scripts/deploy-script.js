const hre = require("hardhat");

async function main() {
  const baseURI = "base uri";
  const BuddhaNFT = await hre.ethers.getContractFactory("BuddhaNFT");
  const buddhanft = await BuddhaNFT.deploy();

  await buddhanft.deployed(baseURI);

  console.log("BuddhaNFT deployed to:", buddhanft.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
