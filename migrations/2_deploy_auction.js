const Auction = artifacts.require("Auction");

module.exports = function (deployer) {
  const itemName = "Laptop";
  const minimumBid = web3.utils.toWei("0.1", "ether");
  const durationInSeconds = 3600;

  deployer.deploy(Auction, itemName, minimumBid, durationInSeconds);
};
