// const { ethers } = require("hardhat");
// const fs = require("fs");
// const dotenv = require("dotenv");

// // Config the dotenv file
// dotenv.config();

// // Create a main function
// async function main() {
//     try {

//         const signers = await ethers.getSigner();
//         console.log("Number of signers:", signers.length);
//         const [deployer] = signers;
//         if (!deployer) {
//             throw new Error("No deployer account found");
//         }
//         console.log("Deploying contracts with the account", deployer.address);
    
//         const balance = await deployer.getBalance();
//         console.log("Accoint balance:", hre.ethers.utils.formatEther(balance));
    
//         const vrfCoordinatorV2Address = process.env.VRF_ADDRESS; // address of the VRFCoordinatorV2 contract
//         const subId = process.env.SUB_ID; // subscription ID for Chainlink VRF
//         const keyHash = process.env.KEY_HASH; // key hash for Chainlink VRF
//         const gasLimit = 2500000;
    
//         const argumentsArray = [vrfCoordinatorV2Address, subId, keyHash, gasLimit];
//         const content = "module.exports= " + JSON.stringify(argumentsArray, null, 2) + ";";
//         fs.writeFileSync("./arguments.js", content);
//         console.log("arguments.js file generated successfully.");
    
//         // Deploying OnePiecePersonalityDapp contract
//         const OnePiecePersonalityDapp = await ethers.getContractFactory("OnePieceMint");
    
//         console.log("Deploying OnePiecePersonalityDapp...");
    
//         const onePiecePersonalityDapp = await OnePiecePersonalityDapp.deploy(
//             vrfCoordinatorV2Address,
//             subId,
//             keyHash,
//             gasLimit
//         );
    
//         console.log("OnePiecePersonalityDapp deployed to:", await onePiecePersonalityDapp.getAddress());
//     } catch (error) {
//         console.error("Error in deployment", error);
//     }
// }

// main()
//     .then(() => process.exit(0))
//     .catch((error) => {
//         console.error(error);
//         process.exit(1);
//     });

const { ethers } = require("hardhat");
const fs = require("fs");
const dotenv = require("dotenv");
dotenv.config();

async function main() {
  
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const vrfCoordinatorV2Address = process.env.VRF_ADDRESS; // address of the VRFCoordinatorV2 contract
  const subId = process.env.SUB_ID; // subscription ID for Chainlink VRF
  const keyHash = process.env.KEY_HASH; // key hash for Chainlink VRF
  const gasLimit = 2500000; 

  const argumentsArray = [vrfCoordinatorV2Address, subId, keyHash, gasLimit ]
  const content = "module.exports = " + JSON.stringify(argumentsArray, null, 2) + ";";
  fs.writeFileSync("./arguments.js", content);
  console.log("arguments.js file generated successfully.");

  // Deploying OnePiecePersonalityDapp contract
  const OnePiecePersonalityDapp = await ethers.getContractFactory("OnePieceMint");

  console.log("Deploying OnePiecePersonalityDapp...");

  const onePiecePersonalityDapp = await OnePiecePersonalityDapp.deploy(
    vrfCoordinatorV2Address, 
    subId, 
    keyHash,
    gasLimit);

  console.log("OnePiecePersonalityDapp deployed to:", await onePiecePersonalityDapp.getAddress()); 

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
