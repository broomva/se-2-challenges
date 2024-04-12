pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
  YourToken public yourToken;

  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    uint256 amountOfToken = msg.value * tokensPerEth;

    yourToken.transfer(msg.sender, amountOfToken);

    emit BuyTokens(msg.sender, msg.value, amountOfToken);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner {
    require(address(this).balance > 0, "No balance to withdraw");
    (bool reponse, ) = msg.sender.call{value: address(this).balance}(""); // send all the balance to the owner
    require(reponse, "Withdraw failed");
  }

  // ToDo: create a sellTokens(uint256 _amount) function:
  function sellTokens(uint256 _amount) public {
    uint256 amountOfEth = _amount / tokensPerEth; // 

    require(yourToken.balanceOf(msg.sender) >= _amount, "Insufficient balance");

    yourToken.transferFrom(msg.sender, address(this), _amount);

    (bool response, ) = msg.sender.call{value: amountOfEth}("");
    require(response, "Sell failed");

    emit SellTokens(msg.sender, _amount, amountOfEth);
  }
}
