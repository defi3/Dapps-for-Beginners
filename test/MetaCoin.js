
const MetaCoin = artifacts.require("./MetaCoin.sol");

contract("MetaCoin", (accounts) => {
  it("deploy a new contract", async () => {
    this.coin = await MetaCoin.new(accounts[0]);
  });

  it("check the total supply", async () => {
    total = await this.coin.totalSupply();
    assert.equal(total, 10000, "the total supply should be 10000");
  });

  it("check account balance", async () => {
    balance = await this.coin.balanceOf(accounts[0]);
    assert.equal(balance, 10000, "accounts[0]'s balance should be 10000");

    balance = await this.coin.balanceOf(accounts[1]);
    assert.equal(balance, 0, "accounts[1]'s balance should be 10000");
  });

  it("should transfer amount correctly", async () => {
    await this.coin.transfer(accounts[1], 100, { from: accounts[0] });

    balance = await this.coin.balanceOf(accounts[0]);
    assert.equal(balance, 9900, "accounts[0]'s balance should be 9900");

    balance = await this.coin.balanceOf(accounts[1]);
    assert.equal(balance, 100, "accounts[1]'s balance should be 100");
  });

  it("check account allowance", async () => {
    amount = await this.coin.allowance(accounts[0], accounts[1]);
    assert.equal(amount, 0, "accounts[0] approves accounts[1] to transfer up to 0");

    amount = await this.coin.allowance(accounts[1], accounts[0]);
    assert.equal(amount, 0, "accounts[0] approves accounts[1] to transfer up to 0");
  });

  it("should approve amount correctly", async () => {
    await this.coin.approve(accounts[1], 100, { from: accounts[0] });

    amount = await this.coin.allowance(accounts[0], accounts[1]);
    assert.equal(amount, 100, "accounts[0] approves accounts[1] to transfer up to 100");

    await this.coin.approve(accounts[0], 100, { from: accounts[1] });

    amount = await this.coin.allowance(accounts[1], accounts[0]);
    assert.equal(amount, 100, "accounts[1] approves accounts[0] to transfer up to 100");
  });

  it("should transferFrom amount correctly", async () => {
    await this.coin.transferFrom(accounts[1], accounts[0], 10, { from: accounts[0] });

    balance = await this.coin.balanceOf(accounts[0]);
    assert.equal(balance, 9910, "accounts[0]'s balance should be 9910");

    balance = await this.coin.balanceOf(accounts[1]);
    assert.equal(balance, 90, "accounts[1]'s balance should be 90");
  });
});


