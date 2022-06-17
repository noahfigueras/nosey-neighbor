const { expect } = require("chai");

describe("Nosey Neigbor NFT", function() {
	let deployer, user;

	before(async function() {
		[deployer, user] = await ethers.getSigners();

		//Deploy contract 
		const revealDate = Math.floor(Date.now() / 1000) + 60; //UNIX Timestamp 60s into the future.
		this.nosey = await(await ethers.getContractFactory("NOSEY_NEIGHBOR"))
			.deploy(
				"Nosey Neighbor",
				"NOSEY",
				"https://baseUri.com/",
				"https://notRevealedUri.com",
				revealDate 
			);
	});

	it("mints reserve correctly", async function() {
		const balance = await this.nosey.balanceOf(deployer.address);
		expect(balance).to.be.equal(50);
	});

	it("returns notRevealed URI", async function() {
		expect(await this.nosey.tokenURI(1)).to.equal("https://notRevealedUri.com");
	});

	it("reverts to execute reserve mint after deployment", async function() {
		try {
			await this.nosey._mintReserve();
		} catch (err) {
			expect(err.message).to.be.equal("this.nosey._mintReserve is not a function");
		}
	});

	it("reverts mint on paused contract", async function() {
		const error = 'Error: The Contract is not active at the moment';
		await this.nosey.pause(true);
		await expect(this.nosey.connect(user).pause(true)).to.be.reverted;
		await expect(this.nosey.mint(1)).to.be.revertedWith(error)
		// Reset to active contract
		await this.nosey.pause(false);
	});

	it("reverts on mint amount 0", async function() {
		const error = "Error: Mint amount has to be bigger than 0";
		await expect(this.nosey.connect(user).mint(0)).to.be.revertedWith(error)
	});

	it("reverts on maximum mint amount when 0 balance", async function() {
		const error = "Error: Maximum NFT mint amount exceeded";
		await expect(this.nosey.connect(user).mint(100)).to.be.revertedWith(error)
	});

	it("reverts on maximum mint amount of 3", async function() {
		const error = "Error: Maximum NFT mint amount exceeded";
		await this.nosey.connect(user).mint(3);
		await expect(this.nosey.connect(user).mint(1)).to.be.revertedWith(error)
	});

	it("reverts on maxSupply reached", async function() {
		const error = "Error: Sorry we are sold out";
		let wallets = await ethers.getSigners();
		wallets = wallets.slice(2);
		for(let i = 0; i < 815; i++){
			await this.nosey.connect(wallets[i]).mint(3);
		}
		await expect(this.nosey.connect(wallets[816]).mint(3)).to.be.revertedWith(error);
	});

	it("mints successfully", async function() {
		let wallets = await ethers.getSigners();
		await this.nosey.connect(wallets[818]).mint(2);
		expect(await this.nosey.balanceOf(wallets[818].address)).to.be.equal(2);
	});

	it("returns walletOfOwner", async function() {
		let wallets = await ethers.getSigners();
		const balance = await this.nosey.walletOfOwner(wallets[818].address);
		expect(balance[0]).to.equal(ethers.BigNumber.from(2499));
		expect(balance[1]).to.equal(ethers.BigNumber.from(2500));
	});

	it("returns base URI after 60 sec", async function() {
		expect(await this.nosey.tokenURI(1)).to.equal("https://baseUri.com/1.json");
	});

});
