// require("@nomicfoundation/hardhat-toolbox");
// require("@nomicfoundation/hardhat-verify");

// const dotenv = require("dotenv");
// dotenv.config();

// function privateKey() {
//   if (process.env.PRIVATE_KEY === undefined) {
//     console.error("PRIVATE_KEY is not set in the .env file");
//     return[];
//   }
//   console.log("Private key length:", process.env.PRIVATE_KEY.length);
//   return[process.env.PRIVATE_KEY];
//   // return process.env.PRIVATE_KEY != undefined ? [process.env.PRIVATE_KEY] : [];
// }

// /** @type import('hardhat/config').HardhatUserConfig */
// module.exports = {
//   networks: {
//     mumbai: {
//       // url: "https://polygon-mumbai-pokt.nodies.app",
//       url: "https://rpc-mumbai.maticvigil.com",
//       accounts: privateKey(),
//       chainId: 80001
//     },
//     sepolia: {
//       url: "https://eth-sepolia.public.blastapi.io",
//       accounts: privateKey(),
//     },
//     arbitrum_sepolia: {
//       url: "https://sepolia-rollup.arbitrum.io/rpc",
//       accounts: privateKey(),
//       chainId: 421614
//     }
//   },
//   solidity: {
//     version: "0.8.27",
//     settings: {
//       optimizer: {
//         enabled: true,
//         runs: 1000,
//       },
//     },
//   }, etherscan: {
//     apiKey: process.env.API_KEY,
//   },
// };

require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");

const dotenv = require("dotenv");
dotenv.config();

function privateKey() {
  return process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [];
}

module.exports = {
  networks: {
    mumbai: {
      url: "https://polygon-mumbai-pokt.nodies.app",
      accounts: privateKey(),
    },
    sepolia: {
      url: "https://eth-sepolia.public.blastapi.io",
      accounts: privateKey(),
    },
    arbitrum_sepolia: {
      url: "https://sepolia-rollup.arbitrum.io/rpc",
      accounts: privateKey(),
      chainId: 421614,
      timeout: 60000,
      gasPrice: 'auto',
    }
  },
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },  etherscan: {
    apiKey: process.env.API_KEY, 
  },
};
