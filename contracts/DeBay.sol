//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface IDeBay {
    event AuctionStarted(bytes32 auctionId);
    event Bid(bytes32 auctionId, address bidder, uint256 bid);
    event AuctionEnded(bytes32 auctionId, address winner, uint256 winningBid);

    /**
     * @dev Starts an auction, emits event AuctionStarted
     * Must check if auction already exists
     */
    function startAuction(
        string calldata name,
        string calldata imgUrl,
        string calldata description,
        uint256 floor, // Minimum bid price
        uint256 deadline // To be compared with block.timestamp
    ) external;

    /**
     * @dev Bids on an auction using external funds, emits event Bid
     * Must check if auction exists && auction hasn't ended && bid isn't too low
     */
    function bid(bytes32 auctionId) external payable;

    /**
     * @dev Bids on an auction using existing funds, emits event Bid
     * Must check if auction exists && auction hasn't ended && bid isn't too low
     */
    function bid(bytes32 auctionId, uint256 amount) external;

    /**
     * @dev Settles an auction, emits event AuctionEnded
     * Must check if auction has already ended
     */
    function settle(bytes32 auctionId) external;

    /**
     * @dev Users can deposit more funds into the contract to be used for future bids
     */
    function deposit() external payable;

    /**
     * @dev Users can withdraw funds that were previously deposited
     */
    function withdraw() external;
}

contract DeBay is Ownable, Pausable, IDeBay {
    function getAuctionId(
        address initiator,
        uint256 deadline,
        string calldata name,
        string calldata imgUrl,
        string calldata description
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(initiator, deadline, name, imgUrl, description)
            );
    }
}
