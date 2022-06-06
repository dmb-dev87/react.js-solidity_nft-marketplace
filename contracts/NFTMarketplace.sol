//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemCounter;
    Counters.Counter private _itemSoldCounter;

    address payable public marketowner;
    uint256 public listingPrice = 0.025 ether;

    enum State {
        Created,
        Released,
        Inactive
    }

    enum FetchOperator {
        ActiveItems,
        MyPurchasedItems,
        MyCreatedItems
    }

    struct MarketItem {
        uint256 id;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable buyer;
        uint256 price;
        State state;
    }

    mapping(uint256 => MarketItem) private marketItems;

    event MarketItemCreated(
        uint256 indexed id,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address buyer,
        uint256 price,
        State state
    );

    event MarketItemSold(
        uint256 indexed id,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address buyer,
        uint256 price,
        State state
    );

    constructor() {
        marketowner = payable(msg.sender);
    }

    function setListingPrice(uint256 _listingPrice) public onlyOwner {
        listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be at least 1 wei!");

        require(
            msg.value == listingPrice,
            "Price mut be equal to listing price!"
        );

        require(
            IERC721(nftContract).getApproved(tokenId) == address(this),
            "NFT must be approved to market!"
        );

        _itemCounter.increment();
        uint256 id = _itemCounter.current();

        marketItems[id] = MarketItem(
            id,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            State.Created
        );

        emit MarketItemCreated(
            id,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            State.Created
        );
    }

    function deleteMarketItem(uint256 itemId) public nonReentrant {
        require(itemId <= _itemCounter.current(), "id must <= item count!");

        require(
            marketItems[itemId].state == State.Created,
            "Item must be on market!"
        );

        MarketItem storage item = marketItems[itemId];

        require(
            IERC721(item.nftContract).ownerOf(item.tokenId) == msg.sender,
            "must be the owner!"
        );

        require(
            IERC721(item.nftContract).getApproved(item.tokenId) ==
                address(this),
            "NFT must be approved to market!"
        );

        item.state = State.Inactive;

        emit MarketItemSold(
            itemId,
            item.nftContract,
            item.tokenId,
            item.seller,
            address(0),
            0,
            State.Inactive
        );
    }

    function createMarketSale(address nftContract, uint256 id)
        public
        payable
        nonReentrant
    {
        MarketItem storage item = marketItems[id];
        uint256 price = item.price;
        uint256 tokenId = item.tokenId;

        require(msg.value == price, "Please submit the asking price!");

        require(
            IERC721(nftContract).getApproved(tokenId) == address(this),
            "NFT must be approved to market!"
        );

        IERC721(nftContract).transferFrom(item.seller, msg.sender, tokenId);

        payable(marketowner).transfer(listingPrice);
        item.seller.transfer(msg.value);

        item.buyer = payable(msg.sender);
        item.state = State.Released;
        _itemSoldCounter.increment();

        emit MarketItemSold(
            id,
            nftContract,
            tokenId,
            item.seller,
            msg.sender,
            price,
            State.Released
        );
    }

    function fetchActiveItems() public view returns (MarketItem[] memory) {
        return fetchHelper(FetchOperator.ActiveItems);
    }

    function fetchMyPurchasedItems() public view returns (MarketItem[] memory) {
        return fetchHelper(FetchOperator.MyPurchasedItems);
    }

    function fetchMyCreatedItems() public view returns (MarketItem[] memory) {
        return fetchHelper(FetchOperator.MyCreatedItems);
    }

    function fetchHelper(FetchOperator _op)
        private
        view
        returns (MarketItem[] memory)
    {
        uint256 total = _itemCounter.current();

        uint256 itemCount = 0;

        for (uint256 i = 1; i <= total; i++) {
            if (isCondition(marketItems[i], _op)) {
                itemCount++;
            }
        }

        uint256 index = 0;
        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint256 i = 1; i <= total; i++) {
            if (isCondition(marketItems[i], _op)) {
                items[index] = marketItems[i];
                index++;
            }
        }

        return items;
    }

    function isCondition(MarketItem memory item, FetchOperator _op)
        private
        view
        returns (bool)
    {
        if (_op == FetchOperator.MyCreatedItems) {
            return
                (item.seller == msg.sender && item.state != State.Inactive)
                    ? true
                    : false;
        } else if (_op == FetchOperator.MyPurchasedItems) {
            return (item.buyer == msg.sender) ? true : false;
        } else if (_op == FetchOperator.ActiveItems) {
            return
                (item.buyer == address(0) &&
                    item.state == State.Created &&
                    (IERC721(item.nftContract).getApproved(item.tokenId) ==
                        address(this)))
                    ? true
                    : false;
        } else {
            return false;
        }
    }
}
