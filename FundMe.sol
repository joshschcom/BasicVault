//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "./PriceConverter.sol";

error NotOwner();   

contract FundMe {
    using PriceConverter for uint256;
   
    uint256 public constant MINIMUM_USD = 50 * 1e18; // 1 * 10 ** 18

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable owner;

    constructor(){
        owner = msg.sender;
    }

    function fund() public payable {
        // Want to be able to set a minimum fund amount in Usd
        // How do we send ETH to this contract?
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn`t send enough!"); //1e18 == 1 * 10 **18
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;   
    }

    function withdraw() public onlyOwner {
        
        /* starting Index, ending index, step amount */
        //funderindex++ is the same as funderIndex = funderIndex + 1
        for(uint256 funderIndex =0; funderIndex < funders.length; funderIndex++){
            //code
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //reset array
        funders = new address[](0);

        //actually withdraw funds
        //transfer
        //payable(msg.sender).transfer(address(this).balance);
        //send
        //bool sendSuccess = payable(msg.sender).transfer(address(this).balance);
        //require(sendSuccess, "Send failed");
        //call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner {
       // require(msg.sender == owner, "Sender is not owner!");
       if(msg.sender != owner) { revert NotOwner(); }
        _;
    }

    //What happens when someone sends us Ether without calling "fund()"?

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }


}
