//Deployment of SmartContract.sol to provided network
async function main() {
    //Set Constructor Variables
    const NAME = "Nosey Neighbor";
    const SYMBOL = "NOSEY";
	const BASE_URI = "https://baseUri.com/"; //URL of metadata
	const NOT_REVEALED_URI = "https://notRevealedUri.com"; //URL of metadata not revealed
    const REVEAL_DATE = 1637027102; // UNIX Timestamp
    
    //Get Contract
    const Contract = await ethers.getContractFactory("NOSEY_NEIGHBOR");
    //Deploy Contract
    const contract = await Contract.deploy(NAME, SYMBOL, BASE_URI, NOT_REVEALED_URI, REVEAL_DATE)
    await contract.deployTransaction.wait();
    console.log(NAME, "deployed to:", contract.address);
}

main()
    .then(() => process.exit(0))
    .catch((err) => {
        console.error(err);
        process.exit(1);
    })

