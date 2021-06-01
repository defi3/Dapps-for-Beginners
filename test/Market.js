
const Token = artifacts.require("./token/FaucetToken.sol");
const Market = artifacts.require("./lend/Market.sol");
const Controller = artifacts.require('./lend/Controller.sol');

contract("Market", (accounts) => {
  const alice = accounts[0];
  const bob = accounts[1];
  const charlie = accounts[2];

  const MANTISSA = 1e6;
  const FACTOR = 1e18;
  const BLOCKS_PER_YEAR = 1e6;
  const ANNUAL_RATE = "1000000000000000000000";	// FACTOR / 1000 * BLOCKS_PER_YEAR = 1e21
  const UTILIZATION_RATE_FRACTION = "1000000000000000000000";	// FACTOR / 1000 * BLOCKS_PER_YEAR = 1e21

  it("initialize state", async () => {
    this.token = await Token.new("DAI", "DAI", 1e6, 0, { from: alice });
    this.market = await Market.new(this.token.address, ANNUAL_RATE, BLOCKS_PER_YEAR, UTILIZATION_RATE_FRACTION, { from: alice });

    this.token2 = await Token.new("BAT", "BAT", 1e6, 0, { from: bob });
    this.market2 = await Market.new(this.token2.address, ANNUAL_RATE, BLOCKS_PER_YEAR, UTILIZATION_RATE_FRACTION, { from: bob });

    this.controller = await Controller.new({ from: alice });

    await this.controller.setCollateralFactor(1 * MANTISSA);
    await this.controller.setLiquidationFactor(MANTISSA / 2);

    await this.controller.addMarket(this.market.address);
    await this.controller.addMarket(this.market2.address);

    await this.controller.setPrice(this.market.address, 1);
    await this.controller.setPrice(this.market2.address, 2);
  });

  it("check initial state", async () => {
    amount = await this.market.supplyOf(alice);
    assert.equal(amount, 0);

    amount = await this.market.supplyOf(bob);
    assert.equal(amount, 0);

    amount = await this.market.supplyOf(charlie);
    assert.equal(amount, 0);

    balance = await this.token.balanceOf(this.market.address);
    assert.equal(balance, 0);

    supply = await this.market.totalSupply();
    assert.equal(supply, 0);

    factor = await this.market.FACTOR();
    assert.equal(factor, 1e18);

    cash = await this.market.getCash();
    assert.equal(cash, 0);

    supplyIndex = await this.market.supplyIndex();
    assert.equal(supplyIndex, FACTOR);

    borrowIndex = await this.market.borrowIndex();
    assert.equal(borrowIndex, FACTOR);

    borrowRate = await this.market.baseBorrowRate();
    assert.equal(borrowRate, FACTOR / 1000);

    borrowRate = await this.market.borrowRatePerBlock();
    assert.equal(borrowRate, FACTOR / 1000);

    supplyRate = await this.market.supplyRatePerBlock();
    assert.equal(supplyRate, 0);

    accrualBlockNumber = await this.market.accrualBlockNumber();
    assert.ok(accrualBlockNumber > 0);

    borrowBy = await this.market.borrowBy(alice);
    assert.equal(borrowBy, 0);

    updatedBorrowBy = await this.market.updatedBorrowBy(alice);
    assert.equal(updatedBorrowBy, 0);

    assert.equal(await this.market.utilizationRate(0, 0, 0), 0);
    assert.equal(await this.market.utilizationRate(1000, 1000, 0), FACTOR / 2);
    assert.equal(await this.market.utilizationRate(2000, 1000, 1000), FACTOR / 2);
  });
});


