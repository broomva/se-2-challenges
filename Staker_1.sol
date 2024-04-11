// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  mapping ( address => uint256 ) public balances;

  uint256 public constant threshold = 0.00001 ether;
  uint256 public deadline = block.timestamp + 30 seconds;
  bool public openForWithdraw = false;

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

  event Stake(address, uint256);

  function stake() payable public {
    require(msg.value > 0, "You need to stake more than 0");
    // require(block.timestamp < deadline, "Deadline has passed");
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

  function execute() public {
    require(block.timestamp > deadline, "Deadline has not passed");
    if (address(this).balance >= threshold) { // Check if the contract balance is greater than or equal to the threshold
      exampleExternalContract.complete{value: address(this).balance}();
      openForWithdraw = true;
    }
    else {
      openForWithdraw = false;
    }
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance

  function withdraw() public {
    require(openForWithdraw, "Not open for withdraw");
    require(address(this).balance < threshold, "Threshold met!");
    require(balances[msg.sender] > 0, "You have no balance to withdraw");
    uint256 amount = balances[msg.sender]; // Save the balance of the current address to a variable
    balances[msg.sender] = 0; // Set the balance in the mapping/contract to 0 for the current address
    payable(msg.sender).transfer(amount); // Transfer the saved balance to the current address
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    }
    return deadline - block.timestamp;
  }


  // Add the `receive()` special function that receives eth and calls stake()

  receive() external payable {
    stake();
  }

}
