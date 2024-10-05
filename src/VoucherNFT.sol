// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract VoucherNFT is ERC721 {
    uint256 private _nextVoucherId = 1; // Start at 1 for the voucher ID

    constructor() ERC721("VoucherNFT", "VNFT") {}

    // Function to mint a voucher (unique NFT)
    function mintVoucher(address recipient) public returns (uint256) {
        uint256 newVoucherId = _nextVoucherId; // Assign the next available ID

        _mint(recipient, newVoucherId);

        _nextVoucherId++; // Increment the ID for the next voucher

        return newVoucherId;
    }

    // Function to retrieve both the IDs and URIs of vouchers owned by a specific address
    function vouchersOfOwner(
        address owner
    ) public view returns (uint256[] memory) {
        uint256 voucherCount = balanceOf(owner);
        uint256[] memory voucherIds = new uint256[](voucherCount);
        uint256 counter = 0;

        // Iterate from 1 to the current highest voucher ID
        for (uint256 i = 1; i < _nextVoucherId; i++) {
            if (ownerOf(i) == owner) {
                voucherIds[counter] = i;
                counter++;
            }
        }
        return voucherIds;
    }
}
