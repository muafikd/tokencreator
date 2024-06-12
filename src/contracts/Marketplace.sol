// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Импортируем стандартные интерфейсы ERC-721 и ERC-1155 для взаимодействия с NFT.
import "../../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
// Импортируем вспомогательные функции для проверки адресов.
import "../../node_modules/@openzeppelin/contracts/utils/Address.sol";
// Импортируем собственный контракт для управления правами владельца.
import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";

// Контракт управления NFT-маркетплейсом.
contract NFTMarketplace is Ownable {
    using Address for address;

    // Структура для представления размещения NFT на продажу.
    struct Listing {
        address owner; // Владелец NFT.
        address nftContract; // Контракт NFT, к которому принадлежит токен.
        uint256 tokenId; // Идентификатор токена.
        uint256 price; // Цена продажи в эфире.
        bool isERC1155; // Тип NFT (ERC-1155 или ERC-721).
    }

    // Храним все размещенные на продажу NFT.
    mapping(uint256 => Listing) public listings;
    uint256 public listingCount; // Общее количество размещений.

    // События для отслеживания операций на маркетплейсе.
    event NFTListed(
        uint256 listingId,
        address indexed owner,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 price
    );
    event NFTSold(uint256 listingId, address indexed buyer, uint256 price);
    event ListingCancelled(uint256 listingId);

    constructor() Ownable(msg.sender) {}

    // Функция для размещения NFT на продажу.
    function listNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        bool isERC1155
    ) external {
        // Убедимся, что цена больше нуля.
        require(price > 0, "Price must be greater than zero");

        // Убедимся, что контракт маркетплейса имеет необходимые разрешения на управление NFT.
        if (isERC1155) {
            require(
                IERC1155(nftContract).isApprovedForAll(
                    msg.sender,
                    address(this)
                ),
                "Marketplace not approved to handle NFTs"
            );
        } else {
            require(
                IERC721(nftContract).getApproved(tokenId) == address(this) ||
                    IERC721(nftContract).isApprovedForAll(
                        msg.sender,
                        address(this)
                    ),
                "Marketplace not approved to handle NFT"
            );
        }

        // Увеличиваем общий счетчик размещений.
        listingCount++;
        // Сохраняем информацию о новом размещении.
        listings[listingCount] = Listing(
            msg.sender,
            nftContract,
            tokenId,
            price,
            isERC1155
        );

        // Эмитируем событие, чтобы зафиксировать размещение NFT.
        emit NFTListed(listingCount, msg.sender, nftContract, tokenId, price);
    }

    // Функция для покупки NFT.
    function buyNFT(uint256 listingId) external payable {
        // Получаем информацию о размещении.
        Listing storage listing = listings[listingId];
        // Убедимся, что NFT действительно выставлен на продажу.
        require(listing.price > 0, "NFT not listed for sale");
        // Убедимся, что пользователь отправил правильное количество эфира.
        require(msg.value == listing.price, "Incorrect Ether value sent");

        // Передача NFT новому владельцу.
        if (listing.isERC1155) {
            IERC1155(listing.nftContract).safeTransferFrom(
                listing.owner,
                msg.sender,
                listing.tokenId,
                1,
                ""
            );
        } else {
            IERC721(listing.nftContract).transferFrom(
                listing.owner,
                msg.sender,
                listing.tokenId
            );
        }

        // Отправляем полученные средства продавцу.
        payable(listing.owner).transfer(listing.price);

        // Эмитируем событие, чтобы зафиксировать продажу NFT.
        emit NFTSold(listingId, msg.sender, listing.price);

        // Удаляем информацию о продаже, так как NFT больше не на продаже.
        delete listings[listingId];
    }

    // Функция для отмены продажи NFT.
    function cancelListing(uint256 listingId) external {
        Listing storage listing = listings[listingId];
        // Убедимся, что отмену продажи инициирует владелец.
        require(
            msg.sender == listing.owner,
            "Only the owner can cancel the listing"
        );

        // Эмитируем событие об отмене продажи.
        emit ListingCancelled(listingId);

        // Удаляем информацию о размещении, поскольку продажа отменена.
        delete listings[listingId];
    }

    // Функция для получения общего количества размещенных NFT.
    function getTotalListings() external view returns (uint256) {
        return listingCount;
    }

    // Функция для получения информации о конкретном размещении.
    function getListing(uint256 listingId)
        external
        view
        returns (Listing memory)
    {
        return listings[listingId];
    }
}