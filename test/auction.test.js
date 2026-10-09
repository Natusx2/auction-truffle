const Auction = artifacts.require("Auction");

contract("Auction", (accounts) => {
  const [owner, bidder1, bidder2] = accounts;
  const minimumBid = web3.utils.toWei("1", "ether");

  it("accepts bids and selects the highest bidder as winner", async () => {
    const auction = await Auction.new("Phone", minimumBid, 3600, { from: owner });

    await auction.bid({
      from: bidder1,
      value: web3.utils.toWei("1", "ether"),
    });

    await auction.bid({
      from: bidder2,
      value: web3.utils.toWei("2", "ether"),
    });

    await auction.endAuction({ from: owner });

    const winner = await auction.winner();
    const winningBid = await auction.winningBid();
    const bidder1Refund = await auction.refunds(bidder1);

    assert.equal(winner, bidder2);
    assert.equal(winningBid.toString(), web3.utils.toWei("2", "ether"));
    assert.equal(bidder1Refund.toString(), web3.utils.toWei("1", "ether"));
  });

  it("allows owner to cancel auction and return bids through refunds", async () => {
    const auction = await Auction.new("Tablet", minimumBid, 3600, { from: owner });

    await auction.bid({
      from: bidder1,
      value: web3.utils.toWei("1", "ether"),
    });

    await auction.cancelAuction({ from: owner });

    const cancelled = await auction.cancelled();
    const refund = await auction.refunds(bidder1);

    assert.equal(cancelled, true);
    assert.equal(refund.toString(), web3.utils.toWei("1", "ether"));
  });
});
