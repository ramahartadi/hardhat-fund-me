// SPDX-License-Identifier: MIT
// Pragma
pragma solidity ^0.8.7;
// Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";
// Errod Codes
error FundMe__NotOwner();

// Interfaces, Libraries, Contracts

/**
 * @title A contract for crowd funding
 * @author Rama Destrian Hartadi
 * @notice This contract is for demonstration purposes only
 * @dev This implements price feeds from Chainlink
 */
contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    // State Variables
    
    mapping(address => uint256) public s_addressToAmountFunded;
    address[] public s_funders;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address public /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;

    AggregatorV3Interface public s_priceFeed;

    modifier onlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // Functions Order:
    // 1. Constructor
    // 2. Receive
    // 3. Fallback
    // 4. External
    // 5. Public
    // 6. Internal
    // 7. Private

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    /**
     * @notice This function funds this contract
     * @dev This implements price feeds from Chainlink
     */

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }
    //104444
    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function cheaperWithdraw() public payable onlyOwner{
        address[] memory funders = s_funders;
        // mappings can't be in memory, sorry!
        for(uint256 funderIndex =0 ; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder];
        }
        s_funders = new address[](0);
            (bool success, ) = i_owner.call{value: address(this).balance}("");
            require(success, "Failed to send Ether");
        
    }
}
