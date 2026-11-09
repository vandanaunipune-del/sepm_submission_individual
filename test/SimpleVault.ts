import { expect } from "chai";
import { network } from "hardhat";

describe("SimpleVault ABI", function () {
  it("exposes the expected functions without deploying the contract", async function () {
    const { artifacts } = await import("hardhat");
    const artifact = await artifacts.readArtifact("SimpleVault");
    const functions = artifact.abi.filter((entry) => entry.type === "function");

    expect(functions.map((entry) => entry.name)).to.include.members([
      "balances",
      "deposit",
      "withdraw",
    ]);

    const deposit = functions.find((entry) => entry.name === "deposit");
    const withdraw = functions.find((entry) => entry.name === "withdraw");

    expect(deposit?.stateMutability).to.equal("payable");
    expect(withdraw?.stateMutability).to.equal("nonpayable");
  });
});

describe("SimpleVault deposit limits", function () {
  it("accepts deposits at the minimum and maximum limits", async function () {
    const { ethers } = await network.connect();
    const [depositor] = await ethers.getSigners();
    const vault = await ethers.deployContract("SimpleVault");
    const minimum = ethers.parseEther("1");
    const maximum = ethers.parseEther("5");

    await (await vault.deposit(minimum, { value: minimum })).wait();
    await (await vault.deposit(maximum, { value: maximum })).wait();

    expect(await vault.balances(depositor.address)).to.equal(minimum + maximum);
  });

  it("rejects deposits below the minimum limit", async function () {
    const { ethers } = await network.connect();
    const vault = await ethers.deployContract("SimpleVault");
    const minimum = ethers.parseEther("1");
    const amount = minimum - 1n;

    await expect(vault.deposit(amount, { value: amount }))
      .to.be.revertedWithCustomError(vault, "DepositBelowMinimum")
      .withArgs(amount, minimum);
  });

  it("rejects deposits above the maximum limit", async function () {
    const { ethers } = await network.connect();
    const vault = await ethers.deployContract("SimpleVault");
    const maximum = ethers.parseEther("5");
    const amount = maximum + 1n;

    await expect(vault.deposit(amount, { value: amount }))
      .to.be.revertedWithCustomError(vault, "DepositAboveMaximum")
      .withArgs(amount, maximum);
  });
});
